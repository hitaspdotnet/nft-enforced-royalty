import "./structs";


message(0x693d3950) GetRoyaltyParams {
  query_id: Int as uint64;
}

message(0xa8cb00ad) ReportRoyaltyParams {
  query_id: Int as uint64;
  numerator:  Int as uint16;
  denominator: Int as uint16;
  destination: Address;
}

message(0x5fcc3d14) Transfer { 
  query_id: Int as uint64;            
  new_owner: Address; 
  response_destination: Address; 
  custom_payload: Cell?; 
  forward_amount: Int as coins; 
  forward_payload: Slice as remaining; 
}

message(0x05138d91) OwnershipAssigned{
  query_id: Int as uint64;
  prev_owner: Address;
  forward_payload: Slice as remaining; 
}

message(0x2fcb26a2) GetStaticData { 
  query_id: Int as uint64;
}

message(0x8b771735) ReportStaticData{
  query_id: Int as uint64;
  item_index: Int;
  collection_address: Address;
}

message(0xd53276db) Excesses {
  query_id: Int as uint64;
}

message(0xd136d3b3) TakeExcess {
  query_id: Int as uint64;
}

message NftDeploy {
  query_id: Int as uint64;
  item_index: Int as uint64;
  item_owner: Address;
  individual_content: Cell;
}

message(0x1f04537a) NftDestroy {
    query_id: Int as uint64;
}

message RequestNftDeploy {
  query_id: Int as uint64;
  item_index: Int as uint64;
  item_owner: Address;
  item_value: Int as coins;
  item_content: Cell;
}

message RequestGrant {
  query_id: Int as uint64;
  ungranted_transfers: Int as uint16;
  current_owner: Address;
  new_owner: Address; 
  response_destination: Address; 
  custom_payload: Cell?; 
  forward_amount: Int as coins; 
  forward_payload: Slice as remaining; 
}

message ItemGranted { 
  query_id: Int as uint64;            
  new_owner: Address; 
  response_destination: Address; 
  custom_payload: Cell?; 
  forward_amount: Int as coins; 
  forward_payload: Slice as remaining; 
}

message GrantedTransfer { 
  query_id: Int as uint64;            
  new_owner: Address; 
  response_destination: Address; 
  custom_payload: Cell?; 
  forward_amount: Int as coins; 
  forward_payload: Slice as remaining; 
}

message GetGrantData { 
  query_id: Int as uint64;
}

message ReportGrantData{
  query_id: Int as uint64;
  is_granted: Bool;
  ungranted_transfers: Int as uint16;
  prev_owners: map<Address, Int>;
  current_owner: Address;
}