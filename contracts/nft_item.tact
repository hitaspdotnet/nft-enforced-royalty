import "@stdlib/ownable";
import "@stdlib/deploy";
import "./imports/messages";
import "./imports/globals";
import "./imports/nft-new-standard";

contract NftItem with INFTNewStandard {
    is_initialized: Bool = false;
    collection_address: Address;
    owner: Address;
    item_index: Int as uint64;
    individual_content: Cell;
    is_granted: Bool = true;
    ungranted_transfers: Int as uint16 = 0;
    prev_owners: map<Address, Int>;
    
    init(collection_address: Address, item_index: Int) {
        self.collection_address = collection_address;
        self.item_index = item_index;

        self.owner = self.collection_address;
        self.individual_content = emptyCell();
    }

    receive(msg: NftDeploy) {
        require(sender() == self.collection_address, "Invalid Sender");
        require(self.item_index == msg.item_index, "Invalid index");
        require(!self.is_initialized, "Already initialized");
        self.owner = msg.item_owner;
        self.individual_content = msg.individual_content;
        self.is_initialized = true;
    }

    receive(msg: NftDestroy) {
        require(sender() == self.owner, "Invalid Owner");
        self.owner = myAddress();
        send(SendParameters{
            to: sender(),
            value: 0,
            mode: SendRemainingBalance,
            body: Excesses{
                query_id: msg.query_id
            }.toCell()
        });
    }
}
