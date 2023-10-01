import "@stdlib/ownable";
import "@stdlib/deploy";
import "./imports/messages";
import "./imports/globals";
import "./imports/royalty";
import "./nft_item";

fun get_percent(a: Int, percent: Int, factor: Int) : Int {
    if (factor == 0) {
        return 0;
    } else {
        let val: Int = (a * percent) / factor;
        return val;
    }
}

contract NftCollection with Ownable, Deployable, IHaveRoyalty {
    owner: Address;
    next_item_index: Int as uint64 = 0;
    collection_content: Cell;
    royalty_params: RoyaltyParams;

    init(data: NftCollectionData) {
        self.owner = data.owner;
        self.collection_content = data.collection_content;
        self.royalty_params = data.royalty_params;
    }

    receive(msg: RequestNftDeploy) {
        self.requireOwner();
        
        require(msg.item_index <= self.next_item_index, "Invalid index");

        let nft_init: StateInit = self.getNftItemInit(msg.item_index);
        let nft_address: Address = contractAddress(nft_init);

        send(SendParameters{
            to: nft_address,
            value: msg.item_value,
            mode: SendPayGasSeparately,
            bounce: false,
            data: nft_init.data,
            code: nft_init.code,
            body: NftDeploy{
                query_id: msg.query_id,
                item_index: msg.item_index,
                item_owner: msg.item_owner,
                individual_content: msg.item_content
            }.toCell()
        });

        if(msg.item_index == self.next_item_index) {
            self.next_item_index = self.next_item_index + 1;
        }
    }

    receive(msg: RequestGrant) {
        let royalty_amount: Int = get_percent(context().value, self.royalty_params.numerator, self.royalty_params.denominator);
        let debt : Int = msg.ungranted_transfers * royalty_amount;
        let restAmount: Int = context().value - minTonsForStorage - gasConsumption - debt;
        require(restAmount >= 0, "Insufficient amount sent");
        
        if(debt > 0){
            send(SendParameters{
                to: self.royalty_params.destination,
                value: debt,
                mode: SendPayGasSeparately,
                body: "NFT item granted".asComment()
            });
        }
      
        send(SendParameters{
            to: sender(),
            value: restAmount,
            mode: SendRemainingValue,
            body: "ItemGranted".asComment()
        });
    }

    get fun getNftItemInit(item_index: Int): StateInit {
        return initOf NftItem(myAddress(), item_index);
    }
    get fun get_collection_data(): NftCollectionData {
        return NftCollectionData{next_item_index: self.next_item_index, collection_content: self.collection_content, owner: self.owner, royalty_params: self.royalty_params};
    }
    get fun get_nft_address_by_index(item_index: Int): Address {
        return contractAddress(self.getNftItemInit(item_index));
    }
    get fun get_nft_content(item_index: Int, individual_content: Cell): Cell { 
        let b: StringBuilder = beginString();
        let ic: String = individual_content.asSlice().asString();
        b.append(ic);
        return b.toCell();
    }
}