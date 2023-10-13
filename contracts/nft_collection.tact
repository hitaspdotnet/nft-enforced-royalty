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
        let n: Int = (a * percent) / factor;
        return n;
    }
}

contract NftCollection with Ownable, Deployable, IHaveRoyalty {
    owner: Address;
    next_item_index: Int as uint64 = 0;
    collection_content: Cell;
    royalty_params: RoyaltyParams;

    // Collection authors should work out the way of valuing their NFTs
    nft_royalty_price: Int as coins = ton("1");
    
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
        
        if (msg.item_index == self.next_item_index) {
            self.next_item_index = self.next_item_index + 1;
        }
    }
    
    receive(msg: RequestGrant) {
        let transfers: Int = msg.ungranted_transfers + 1;    // user needs to pay for ungranted transfers + current one
        
        // NFT can also provide some evidence on its price, but some money can go around it
        // currently, collection sets minimal price for purposes of royalty calculation
        let this_nft_price: Int = max(self.nft_royalty_price, (context().value - ton("0.5")) / transfers);
        
        let royalty_amount: Int = get_percent(this_nft_price, self.royalty_params.numerator, self.royalty_params.denominator);
        let debt: Int = transfers * royalty_amount;
        let restAmount: Int = context().value - minTonsForStorage - gasConsumption - debt;
        require(restAmount > 0, "Insufficient amount sent");
        
        if (debt > 0) {
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
            body: ItemGranted{
                query_id: msg.query_id,
                new_owner: msg.new_owner, 
                response_destination: msg.response_destination, 
                custom_payload: msg.custom_payload, 
                forward_amount: msg.forward_amount,
                forward_payload: msg.forward_payload
            }.toCell()
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
