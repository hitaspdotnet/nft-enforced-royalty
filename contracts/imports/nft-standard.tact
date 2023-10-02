import "@stdlib/ownable";
import "./messages";

trait INFTStandard {
    is_initialized: Bool;
    collection_address: Address;
    owner: Address;
    item_index: Int;
    individual_content: Cell;

    receive(msg: Transfer) {
        let ctx: Context = context();
        
        require(self.is_initialized, "Not initialized");
        require(ctx.sender == self.owner, "Invalid Owner");
        
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

    get fun get_nft_data(): NftItemData {
        return NftItemData{is_initialized: self.is_initialized, item_index: self.item_index, collection_address: self.collection_address, owner: self.owner, individual_content: self.individual_content};
    }
}
