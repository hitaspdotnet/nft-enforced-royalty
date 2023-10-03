import "@stdlib/ownable";
import "./royalty";

trait INFTNewStandard {
    is_initialized: Bool;
    collection_address: Address;
    owner: Address;
    item_index: Int;
    individual_content: Cell;
    
    // TODO: should move to new trait
    is_granted: Bool;
    ungranted_transfers: Int;
    prev_owners: map<Address, Int>;


    fun access_allowed(addr: Address) : Bool {
        if (self.prev_owners.get(addr) != null) {
            return true;
        }
        if (addr == self.owner || addr == myAddress()) {
            return true;
        }
        
        return false;
    }

    // TODO: we should throw if is first ungranted transfer and owner must send request via force flag
    receive(msg: Transfer) {
        let ctx: Context = context();
        
        require(self.is_initialized, "Not initialized");

        require(self.access_allowed(ctx.sender), "Invalid Sender");

        // TODO: should move to new trait
        // self.validate_sender();
        if (ctx.sender != myAddress()) {
            self.is_granted = false;
            self.ungranted_transfers = self.ungranted_transfers + 1;
            self.prev_owners.set(self.owner, self.ungranted_transfers);
        } else {
            self.is_granted = true;
            self.ungranted_transfers = 0;
            self.prev_owners = emptyMap();
        }


        let min: Int = minTonsForStorage - min(minTonsForStorage, myBalance());
        let required: Int = gasConsumption + msg.forward_amount + min;
        if (msg.forward_amount != 0) {
            required = required + ctx.readForwardFee();
        }
        
        let cashback: Int = ctx.value - required;
        require(cashback >= 0, "Invalid Amount");
        
        if (msg.forward_amount != 0) {
            send(SendParameters{
                to: msg.new_owner,
                value: msg.forward_amount,
                mode: SendPayGasSeparately,
                body: OwnershipAssigned{
                    query_id: msg.query_id,
                    prev_owner: self.owner,
                    forward_payload: msg.forward_payload
                }.toCell()
            });
        }
        self.owner = msg.new_owner;
        if (cashback > 0) {
            send(SendParameters{
                to: msg.response_destination,
                value: cashback,
                body: Excesses{
                    query_id: msg.query_id
                }.toCell()
            });
        }
    }
    receive(msg: GetStaticData) {
        send(SendParameters{
            to: sender(),
            value: 0,
            mode: SendRemainingValue,
            body: ReportStaticData{
                query_id: msg.query_id,
                item_index: self.item_index,
                collection_address: self.collection_address
            }.toCell()
        });
    }

    // TODO: should move to new trait
    receive(msg: GrantedTransfer) {
        require(context().sender == self.owner, "Invalid Sender");

        send(SendParameters{
            to: self.collection_address,
            value: 0,
            mode: SendRemainingValue,
            body: RequestGrant{
                query_id: msg.query_id,
                ungranted_transfers: self.ungranted_transfers,
                current_owner: self.owner,
                new_owner: msg.new_owner, 
                response_destination: msg.response_destination, 
                custom_payload: msg.custom_payload, 
                forward_amount: msg.forward_amount,
                forward_payload: msg.forward_payload
            }.toCell()
        });
    }

    // TODO: should move to new trait
    // Internal message
    receive(msg: ItemGranted) {
        require(sender() == self.collection_address, "Invalid Sender");
        send(SendParameters{
                to: myAddress(),
                value: 0,
                mode: SendRemainingValue,
                body: Transfer{
                    query_id: msg.query_id,            
                    new_owner: msg.new_owner, 
                    response_destination: msg.response_destination, 
                    custom_payload: msg.custom_payload, 
                    forward_amount: msg.forward_amount,
                    forward_payload: msg.forward_payload
                }.toCell()
            });
    }

    // TODO: should move to new trait
    // Internal message
    receive(msg: GetGrantData) {
        require(sender() == self.collection_address, "Invalid Sender");

        self.reply(ReportGrantData{
                query_id: msg.query_id,
                is_granted: self.is_granted,
                ungranted_transfers: self.ungranted_transfers,
                prev_owners: self.prev_owners,
                current_owner: self.owner
            }.toCell());
    }

    get fun get_nft_data(): NftItemData {
        return NftItemData{is_initialized: self.is_initialized, item_index: self.item_index, collection_address: self.collection_address, owner: self.owner, individual_content: self.individual_content};
    }

    // TODO: should move to new trait
    get fun grant_status(): Bool {
        return self.is_granted;
    }
}
