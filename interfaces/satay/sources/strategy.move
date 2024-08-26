module satay::strategy {
    use std::option;
    use aptos_std::type_info::TypeInfo;
    use aptos_framework::fungible_asset;
    use aptos_framework::fungible_asset::{FungibleAsset, FungibleStore, Metadata};
    use aptos_framework::object;
    use aptos_framework::object::{ExtendRef, Object, ObjectGroup};

    friend satay::vault;

    #[resource_group_member(group = ObjectGroup)]
    struct Strategy has key {
        total_asset: u64,
        /// Timestamp of the last profit collection.
        last_harvest: u64,
        /// Witness type for the strategy.
        witness_type: TypeInfo,
        /// The metadata of the base(deposit) asset.
        base_metadata: Object<Metadata>,
        /// The metadata of the shares asset.
        shares_metadata: Object<Metadata>,
    }

    #[resource_group_member(group = ObjectGroup)]
    struct StrategyController has key {
        manager: address,
        extend_ref: ExtendRef,
    }

    struct StrategyState has store, drop {
        /// The debt limit of the strategy.
        debt_limit: u64,
        /// The current amount of debt of the strategy.
        current_debt: u64,
        /// The time when the strategy was last reported.
        last_report: u64,
    }

    const DEBT_RATIO_MAX: u64 = 10000;

    const ENOT_VAULT_MANAGER: u64 = 0;
    const ENOT_GOVERNANCE: u64 = 1;
    const EDEBT_RATIO_TOO_HIGH: u64 = 2;
    const ESTRATEGY_WITNESS_MISMATCH: u64 = 3;
    const EINVALID_AMOUNT: u64 = 4;
    const EINVALID_SHARES_AMOUNT: u64 = 5;
    const ESTRATEGY_BASE_ASSET_MISMATCH: u64 = 6;
    const ESTRATEGY_DOES_NOT_EXIST: u64 = 7;

    public fun create<T: drop>(manager: &signer, base_asset: Object<Metadata>, _witness: T): Object<Strategy> {
        abort 0
    }

    public fun issue<T>(
        strategy: Object<Strategy>,
        asset: &FungibleAsset,
        _witness: &T
    ): FungibleAsset {
        abort 0
    }

    public fun redeem<T>(
        strategy: Object<Strategy>,
        asset: FungibleAsset,
        _witness: &T
    ): u64 {
        abort 0
    }

    public fun get_strategy_signer<T>(
        strategy: Object<Strategy>,
        _witness: &T
    ): signer {
        abort 0
    }

    public fun base_metadata(strategy: Object<Strategy>): Object<Metadata> acquires Strategy {
        borrow_strategy(&strategy).base_metadata
    }

    inline fun borrow_strategy(strategy: &Object<Strategy>): &Strategy {
        borrow_global<Strategy>(object::object_address(strategy))
    }

    inline fun borrow_strategy_mut(strategy: &Object<Strategy>): &mut Strategy {
        borrow_global_mut<Strategy>(object::object_address(strategy))
    }

    inline fun borrow_strategy_controller(strategy: &Object<Strategy>): &StrategyController {
        borrow_global<StrategyController>(object::object_address(strategy))
    }

    public fun strategy_address(strategy: Object<Strategy>): address {
        object::object_address(&strategy)
    }

    #[view]
    public fun amount_to_shares(strategy: Object<Strategy>, amount: u64): u64 {
        abort 0
    }

    #[view]
    public fun total_asset(vault: Object<Strategy>): u64 {
        fungible_asset::balance(base_store(vault))
    }

    #[view]
    public fun total_shares(vault: Object<Strategy>): u64 acquires Strategy {
        let supply = fungible_asset::supply(shares_metadata(vault));
        (option::destroy_with_default(supply, 0) as u64)
    }

    #[view]
    public fun shares_metadata(strategy: Object<Strategy>): Object<Metadata> acquires Strategy {
        borrow_strategy(&strategy).shares_metadata
    }

    public fun base_store(strategy: Object<Strategy>): Object<FungibleStore> {
        abort 0
    }

    public fun shares_store(strategy: Object<Strategy>): Object<FungibleStore> {
        abort 0
    }
}
