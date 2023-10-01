struct NftCollectionData {
  owner: Address;
  next_item_index: Int as uint64;
  collection_content: Cell;
  royalty_params: RoyaltyParams;
}

struct NftItemData { 
  is_initialized: Bool;
  item_index: Int as uint64;
  collection_address: Address; 
  owner: Address;
  individual_content: Cell;
}

struct RoyaltyParams {
  numerator: Int as uint16;
  denominator: Int as uint16;
  destination: Address;
}