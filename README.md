# nft-enforced-royalty

This is a new type of NFT to enforce traders to payback royalties. It's written for TonTech challenge about new NFT Standard to solve the problem related to royalty.

In this new type, the item has a `granted` label, and if the item is traded outside of the collection, it will receive an ungranted label. Therefore, owners have the freedom to manage their NFT in any way they like. But they will be banned from the future services of the creator (Staking, etc) and their item will be labeled as **Unsupported By Collection**. In order to transfer intellectual property (when `ungranted_transfers = 0`), the transaction must contain value more than royalty at mint's time (roylty * mint pric)

This is the main goal, but in addition to this, we can use the pressure lever to trade through collection and payback royalties:

### Damage
> Unverified item have a **list of previous owners' addresses** (except the creator) and accept **transfer** request from old owners. *Therefore, trading this NFT is very risky*.
We have to get royalty for every transfer of intellectual property, considering that transactions outside the marketplace are not transfers of intellectual property, so having a whitelist of owners from previous addresses is not only not harmful, but sometimes useful. For example, the owner does not have access to the recent wallet, but he can still control item using previus wallet.

### Repair
> To convert a **destroyed/unsupported** NFT to be a **verified** item in the collection: contract can calculate the times of transactions outside the collection and receive royalties based on that and the rules defined by the creator. We need new prop in the royalty params to define compensation for each ungranted transfers. 

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
