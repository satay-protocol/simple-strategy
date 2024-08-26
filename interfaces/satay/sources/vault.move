module satay::vault {
    use std::option::Option;
    use aptos_std::simple_map::SimpleMap;
    use aptos_std::smart_table::SmartTable;
    use aptos_framework::fungible_asset::{FungibleAsset, Metadata};
    use aptos_framework::object::{ExtendRef, Object, ObjectGroup};

    use satay::strategy::{Strategy, StrategyState};

    #[resource_group_member(group = ObjectGroup)]
    struct Vault has key {
        /// The total amount of base asset the vault has deposited into strategies.
        total_debt: u64,
        /// This indicates if the vault is active or not.
        /// An inactive vault does not accept deposits but allows withdrawals.
        is_paused: bool,
        /// The total amount of idle assets in the vault.
        total_available: u64,
        /// A fee that the protocol charges. If not set, the default protocol fee is used.
        protocol_fee: Option<u64>,
        /// The maximum amount of the base asset that can be deposited into the vault.
        deposit_limit: Option<u64>,
        /// The base asset (asset to be deposited) of the vault.
        base_metadata: Object<Metadata>,
        /// The shares asset (asset to be issued) of the vault.
        shares_metadata: Object<Metadata>,
        /// The addresses of the strategies that the vault uses.
        strategies: SimpleMap<Object<Strategy>, StrategyState>,
    }

    #[resource_group_member(group = ObjectGroup)]
    struct VaultController has key {
        manager: address,
        extend_ref: ExtendRef
    }

    #[resource_group_member(group = ObjectGroup)]
    struct RegistryInfo has key {
        vaults: vector<Object<Vault>>,
        strategy_impl: SmartTable<Object<Strategy>, address>
    }

    struct WithdrawalRequest {
        to_withdraw: u64,
        vault: Object<Vault>,
        to_burn: FungibleAsset,
        withdrawn: FungibleAsset,
        liabilities: SimpleMap<Object<Strategy>, u64>,
    }

    // ========== Events =========

    #[event]
    struct VaultCreated has store, drop {
        vault: address,
    }

    #[event]
    struct VaultDeposit has store, drop {
        amount: u64,
        vault: address
    }

    #[event]
    struct VaultPaused has store, drop {
        vault: address
    }

    #[event]
    struct VaultUnpaused has store, drop {
        vault: address
    }

    // ========== Constants =========

    const DEBT_RATIO_MAX: u64 = 10_000;
    const PROTOCOL_FEE_MAX: u64 = 5000;

    const U64_MAX: u64 = 18446744073709551615;

    // ========== Errors =========

    const ENOT_GOVERNANCE: u64 = 0;
    const EDEPOSIT_LIMIT_TOO_LOW: u64 = 0;
    const EPROTOCOL_FEE_TOO_HIGH: u64 = 1;
    const EVAULT_BASE_ASSET_MISMATCH: u64 = 2;
    const EINSUFFICIENT_BALANCE: u64 = 3;
    const EVAULT_NOT_PAUSED: u64 = 4;
    const EVAULT_ALREADY_PAUSED: u64 = 5;
    const ECANNOT_EXCEED_DEPOSIT_LIMIT: u64 = 5;
    const ESTRATEGY_ALREADY_ADDED: u64 = 6;
    const ESTRATEGY_NOT_EXISTS: u64 = 7;
    const EVAULT_ASSET_NOT_INITIALIZED: u64 = 8;
    const EVAULT_SHARES_ASSET_MISMATCH: u64 = 9;
    const EDEBT_RATIO_TOO_HIGH: u64 = 10;
    const ESTRATEGY_STATE_MISMATCH: u64 = 11;
    const ESTRATEGY_STATE_NOT_FOUND: u64 = 12;
    const EVAULT_NOT_ACTIVE: u64 = 14;
    const ESTRATEGY_BASE_METADATA_MISMATCH: u64 = 15;
    const ESTRATEGY_HAS_DEBT: u64 = 16;
    const EVAULT_INSUFFICIENT_DEBT: u64 = 17;
    const EVAULT_WITHDRAWAL_AMOUNT_NOT_ZERO: u64 = 18;
    const EVAULT_DOES_NOT_EXIST: u64 = 19;
    const ESTORE_DOES_NOT_EXIST: u64 = 20;
    const ENOT_GOVERNANCE_OR_MANAGER: u64 = 21;
    const ESTRATEGY_IMPL_ALREADY_ADDED: u64 = 22;
    const ESTRATEGY_IMPL_NOT_FOUND: u64 = 23;


    // ========== Public functions =========

    public fun create(
        account: &signer,
        protocol_fee: Option<u64>,
        deposit_limit: Option<u64>,
        base_metadata: Object<Metadata>
    ): Object<Vault> {
        abort 0
    }

    public fun initialize_withdrawal(
        vault: Object<Vault>,
        shares_asset: FungibleAsset
    ): WithdrawalRequest {
        abort 0
    }

    public fun withdraw(request: &mut WithdrawalRequest) {
        abort 0
    }

    public fun complete_withdrawal(request: WithdrawalRequest): FungibleAsset {
        abort 0
    }

    public fun deposit_strategy_shares(
        strategy_signer: &signer,
        vault: Object<Vault>,
        asset: FungibleAsset
    ) {
        abort 0
    }

    public fun withdraw_strategy_shares(
        strategy_signer: &signer,
        vault: Object<Vault>,
        amount: u64
    ): FungibleAsset {
        abort 0
    }

    public fun collect_withdrawal_asset(request: &mut WithdrawalRequest, asset: FungibleAsset) {
        abort 0
    }

    public fun apply_loss_to_withdrawal(request: &mut WithdrawalRequest, strategy: Object<Strategy>, loss: u64) {
        abort 0
    }

    public fun to_withdraw(withdrawal: &WithdrawalRequest): u64 {
        abort 0
    }
}

