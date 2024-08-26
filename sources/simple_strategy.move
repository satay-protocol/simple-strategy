module simple_strategy::simple_strategy {

    use std::signer;
    use aptos_std::math64;
    use aptos_framework::fungible_asset::{Self, FungibleAsset, Metadata};
    use aptos_framework::object::{Self, ExtendRef, Object, ObjectGroup};
    use aptos_framework::primary_fungible_store;

    use echelon::lending::{Self as echelon, Market};
    use satay::strategy::{Self, Strategy};
    use satay::vault::{Self, Vault, WithdrawalRequest};

    struct StrategyWitness has drop {}

    #[resource_group_member(group = ObjectGroup)]
    struct EchelonUSDTStrategy has key {
        vault: Object<Vault>,
        market: Object<Market>,
        base_strategy: Object<Strategy>,
    }

    #[resource_group_member(group = ObjectGroup)]
    struct EchelonUSDTStrategyController has key {
        extend_ref: ExtendRef,
    }

    const SEED_STRATEGY: vector<u8> = b"0EchelonUSDTStrategy";

    const EINVALID_REDEEM_AMOUNT: u64 = 0;

    // Initialize the strategy with the vault and the base asset
    public entry fun initialize(
        manager: &signer,
        vault: Object<Vault>,
        asset: Object<Metadata>,
        market: Object<Market>
    ) {
        let constructor_ref = object::create_named_object(manager, SEED_STRATEGY);
        let transfer_ref = object::generate_transfer_ref(&constructor_ref);
        object::disable_ungated_transfer(&transfer_ref);

        let strategy_signer = object::generate_signer(&constructor_ref);
        let base_strategy = strategy::create<StrategyWitness>(manager, asset, StrategyWitness {});

        let strategy = EchelonUSDTStrategy { vault, market, base_strategy };
        let controller = EchelonUSDTStrategyController { extend_ref: object::generate_extend_ref(&constructor_ref) };

        move_to(&strategy_signer, controller);
        move_to(&strategy_signer, strategy);
    }

    // Deposit the base asset into the vault and issue the shares to the signer.
    public entry fun deposit(account: &signer, amount: u64) acquires EchelonUSDTStrategy {
        let strategy_address = self_address();
        let account_address = signer::address_of(account);
        let strategy = borrow_global<EchelonUSDTStrategy>(strategy_address);
        let base_metadata = strategy::base_metadata(strategy.base_strategy);

        let asset = primary_fungible_store::withdraw(account, base_metadata, amount);
        let base_asset = deposit_asset(asset);
        primary_fungible_store::deposit(account_address, base_asset);
    }

    public fun deposit_asset(asset: FungibleAsset): FungibleAsset acquires EchelonUSDTStrategy {
        let strategy_address = self_address();
        let strategy = borrow_global<EchelonUSDTStrategy>(strategy_address);

        let shares_asset = strategy::issue(strategy.base_strategy, &asset, &StrategyWitness {});
        let signer = strategy::get_strategy_signer(strategy.base_strategy, &StrategyWitness {});
        echelon::supply_fa(&signer, strategy.market, asset);

        shares_asset
    }

    public fun vault_withdrawal(request: &mut WithdrawalRequest): u64 acquires EchelonUSDTStrategy {
        let to_withdraw = vault::to_withdraw(request);
        if (to_withdraw == 0) return 0;

        let self = borrow_self();
        let witness = &StrategyWitness {};
        let base_strategy = self.base_strategy;

        let total_asset = strategy::total_asset(base_strategy);
        let base_signer = &strategy::get_strategy_signer(base_strategy, witness);

        // Determine how much asset to withdraw, we can't withdraw more than the total asset
        let withdrawable = math64::min(to_withdraw, total_asset);
        if (withdrawable == 0) return 0;

        // convert the withdrawable amount into shares
        let shares_amount = strategy::amount_to_shares(base_strategy, withdrawable);
        let shares_asset = vault::withdraw_strategy_shares(base_signer, self.vault, shares_amount);
        let redeemable = strategy::redeem(self.base_strategy, shares_asset, &StrategyWitness {});

        // Make sure the redeemed amount matches the withdrawable amount
        assert!(redeemable == withdrawable, EINVALID_REDEEM_AMOUNT);

        let redeemed_asset = echelon::withdraw_fa(base_signer, self.market, redeemable);
        let redeemed_amount = fungible_asset::amount(&redeemed_asset);

        if (redeemed_amount > redeemable) {
            let profit = redeemed_amount - redeemable;

            let profit_asset = fungible_asset::extract(&mut redeemed_asset, profit);
            vault::deposit_strategy_shares(base_signer, self.vault, deposit_asset(profit_asset));
        };

        let final_amount = fungible_asset::amount(&redeemed_asset);
        vault::collect_withdrawal_asset(request, redeemed_asset);
        final_amount
    }

    public fun vault(): Object<Vault> acquires EchelonUSDTStrategy {
        let strategy = borrow_global<EchelonUSDTStrategy>(self_address());
        strategy.vault
    }

    public fun self(): Object<EchelonUSDTStrategy> {
        let strategy_address = self_address();

        assert!(object::object_exists<EchelonUSDTStrategy>(strategy_address), 0);
        object::address_to_object<EchelonUSDTStrategy>(strategy_address)
    }

    inline fun borrow_self(): &EchelonUSDTStrategy acquires EchelonUSDTStrategy {
        let strategy_address = self_address();
        borrow_global<EchelonUSDTStrategy>(strategy_address)
    }

    inline fun borrow_controller<T>(): &EchelonUSDTStrategyController acquires EchelonUSDTStrategyController {
        let strategy_address = self_address();
        borrow_global<EchelonUSDTStrategyController>(strategy_address)
    }

    public fun name(): vector<u8> {
        b"EchelonUSDT Strategy"
    }

    public fun version(): vector<u8> {
        b"0.0.3"
    }

    fun self_address(): address {
        // @simple_strategy would be replaced with the actual address of the manager or something else in a real implementation
        object::create_object_address(&@simple_strategy, SEED_STRATEGY)
    }

    fun self_signer(): signer acquires EchelonUSDTStrategyController {
        object::generate_signer_for_extending(&borrow_controller<EchelonUSDTStrategyController>().extend_ref)
    }
}
