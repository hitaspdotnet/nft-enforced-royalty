import { toNano } from 'ton-core';
import { NftItem } from '../wrappers/NftItem';
import { NetworkProvider } from '@ton-community/blueprint';

export async function run(provider: NetworkProvider) {
    const nftItem = provider.open(await NftItem.fromInit());

    await nftItem.send(
        provider.sender(),
        {
            value: toNano('0.05'),
        },
        {
            $$type: 'Deploy',
            queryId: 0n,
        }
    );

    await provider.waitForDeploy(nftItem.address);

    // run methods on `nftItem`
}
