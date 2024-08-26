module echelon::lending {
    use std::string::String;
    use aptos_framework::fungible_asset::{FungibleAsset, Metadata};
    use aptos_framework::object::Object;

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct Market has key {}

    public fun supply_fa(account: &signer, market: Object<Market>, asset: FungibleAsset): u64 {
        abort 0
    }

    public fun withdraw_fa(account: &signer, market: Object<Market>, amount: u64): FungibleAsset {
        abort 0
    }

    public fun account_withdrawable_coins(account: address, market: Object<Market>): u64 {
        abort 0
    }

    public fun claim_reward_fa(account: &signer, market: Object<Market>, asset: Object<Metadata>, name: String): u64 {
        abort 0
    }
}
