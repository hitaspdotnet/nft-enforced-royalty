import { Blockchain, SandboxContract } from '@ton-community/sandbox';
import { toNano } from 'ton-core';
import { NftCollection } from '../wrappers/NftCollection';
import '@ton-community/test-utils';

describe('NftCollection', () => {
    let blockchain: Blockchain;
    let nftCollection: SandboxContract<NftCollection>;

    beforeEach(async () => {
        blockchain = await Blockchain.create();

        nftCollection = blockchain.openContract(await NftCollection.fromInit());

        const deployer = await blockchain.treasury('deployer');

        const deployResult = await nftCollection.send(
            deployer.getSender(),
            {
                value: toNano('0.05'),
            },
            {
                $$type: 'Deploy',
                queryId: 0n,
            }
        );

        expect(deployResult.transactions).toHaveTransaction({
            from: deployer.address,
            to: nftCollection.address,
            deploy: true,
            success: true,
        });
    });

    it('should deploy', async () => {
        // the check is done inside beforeEach
        // blockchain and nftCollection are ready to use
    });
});
