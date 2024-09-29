#[starknet::interface]
trait IAuction<T> {
    fn register_item(ref self: T, item_name: ByteArray);

    fn unregister_item(ref self: T, item_name: ByteArray);

    fn bid(ref self: T, item_name: ByteArray, amount: u32);

    fn get_highest_bidder(self: @T, item_name: ByteArray) -> u32;

    fn is_registered(self: @T, item_name: ByteArray) -> bool;
}

#[starknet::contract]
mod Auction {
    use starknet::event::EventEmitter;
	use super::IAuction;

	#[storage]
    struct Storage {
        bid: Map<ByteArray, u32>,
        register: Map<ByteArray, bool>
    }
    //TODO Implement interface and events .. deploy contract

	#[constructor]
	fn constructor(ref self: ContractState) {
		self.storage.bid = Map::new();
		self.storage.register = Map::new();
	}

	#[external(v0)]
	fn register_item(ref self: ContractState, item_name: ByteArray) {
		self.storage.register.insert(item_name, true);
	}

	fn unregister_item(ref self: ContractState, item_name: ByteArray) {
		self.storage.register.remove(item_name);
	}

	fn bid(ref self: ContractState, item_name: ByteArray, amount: u32) {
		let highest_bid = self.storage.bid.get(&item_name);
		if highest_bid.is_none() {
			self.storage.bid.insert(item_name, amount);
		} else {
			let highest_bid = highest_bid.unwrap();
			if amount > highest_bid {
				self.storage.bid.insert(item_name, amount);
			}
		}
	}

	fn get_highest_bidder(self: @ContractState, item_name: ByteArray) -> u32 {
		let highest_bid = self.storage.bid.get(&item_name);
		if highest_bid.is_none() {
			return 0;
		}
		highest_bid.unwrap()
	}

	fn is_registered(self: @ContractState, item_name: ByteArray) -> bool {
		self.storage.register.contains_key(&item_name)
	}

}
