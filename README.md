# nft-enforced-royalty

This is a new type of NFT to enforce traders to payback royalties. It's written for TonTech challenge about new NFT Standard to solve the problem related to royalty.

In this new type, the item has a `exclusive` status, and if the item is traded outside of the collection, it will receive an `non-exclusive` status. Like when we lend our car, which is a non-fungible asset, to a friend, but we still legally own it even if our friend lends it to someone else. When we want to legally transfer its ownership, we have to pay the transfer fees. This transfer must be done by an authority trusted by the parties to the transaction.

In this case, our subject is an NFT item. The legal owner is the last payer of the royalty. The trusted authority is the NFT collection. 

Non-exclusive NFT can accept a list of all previous owners as those who have access to manage. So, having a whitelist of owners from previous addresses is not only not harmful, but sometimes useful. For example, the owner does not have access to the recent wallet, but can still control item using their previus wallet.

The transfer must be done by Collection, the amount of royalty sent by the marketplace must be greater than the amount of royalty at mint's time. We can ask for royalties for all unofficial transfers or latest one and a penalty defined by the collection's royalty params.

**To legally transfer ownership:**

when `ungranted_transfers = 0`: the transaction must contain value more than royalty at mint's time *(roylty * mint price)*. <br/>

when `ungranted_transfers > 0`: the transaction must contain value more than the result of multiplying the number of transactions in compensation *(ungranted_transfers * (compensation || roylty))*.
```
let compensation: Int = max(self.royalty_params.compensation, (context().value - commonFees) / transfers);

let debt: Int = transfers * compensation;
let restAmount: Int = context().value - commonFees - debt;

// pay to transfer
// require(restAmount > 0, "Insufficient amount sent");

// Reduce debt
// do {
//    // send royalty to creator and reduce ungranted_transfers
// } until (restAmount > 0)

if(restAmount > 0) {
    //send official transfer;
} else {
    //send unofficial transfer;
}
```

Collection does not reject any transfer request, even if the amount of context value is not enough to pay royalty, but changes the number of unofficial transfers. Therefore, owners have the freedom to manage their NFT in any way they like. 

Based on `exclusive` status, collections decide how to provide them with future service (Staking, etc). For example their item will be labeled as **Unsupported By Collection** in the collection explorer.<br/>

## Summary
This is the main goal, we can use the pressure lever to trade through collection and payback royalties:

#### Damage
> Unverified item have a **list of previous owners' addresses** (except the creator) and accept **transfer** request from old owners. *Therefore, trading this NFT is very risky*.

#### Repair
> To convert a **destroyed/unsupported** NFT to be a **exclusive** item in the collection: we can calculate the times of unofficial transfers and receive royalties based on that and the rules defined by the creator.

## Heal Shaya
If you find this repo useful please consider supporting my efforts by sending some TONs the address:

```
UQCjdCk7p7YatNMNpjVND1vMp7HqnF28u2N49P-fPeB93GyG
```

## Project structure

-   `contracts` - source code of all the smart contracts of the project and their dependencies.
-   `wrappers` - wrapper classes (implementing `Contract` from ton-core) for the contracts, including any [de]serialization primitives and compilation functions.
-   `tests` - tests for the contracts.
-   `scripts` - scripts used by the project, mainly the deployment scripts.

## How to use

### Build

`npx blueprint build` or `yarn blueprint build`

### Test

`npx blueprint test` or `yarn blueprint test`

### Deploy or run another script

`npx blueprint run` or `yarn blueprint run`

### Add a new contract

`npx blueprint create ContractName` or `yarn blueprint create ContractName`
