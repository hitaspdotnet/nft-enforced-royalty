import "./structs";

trait IHaveRoyalty {
    royalty_params: RoyaltyParams;

    receive(msg: GetRoyaltyParams) {
        send(SendParameters{
            to: sender(),
            value: 0,
            mode: SendRemainingValue,
            body: ReportRoyaltyParams{
                query_id: msg.query_id, 
                numerator: self.royalty_params.numerator, 
                denominator: self.royalty_params.denominator,  
                destination: self.royalty_params.destination
                }.toCell()
        });
    }

    get fun royalty_params(): RoyaltyParams {
        return self.royalty_params;
    }
}