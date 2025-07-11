use starknet::ContractAddress;

#[starknet::interface]
pub trait IOwnerWriter<TContractState> {
    fn owner(self: @TContractState, owner: ContractAddress) -> bool;
    fn writer(self: @TContractState, writer: ContractAddress) -> bool;
    fn grant_owner(ref self: TContractState, owner: ContractAddress);
    fn revoke_owner(ref self: TContractState, owner: ContractAddress);
    fn grant_writer(ref self: TContractState, writer: ContractAddress);
    fn revoke_writer(ref self: TContractState, writer: ContractAddress);
}


#[starknet::component]
pub mod owners_writers_component {
    use starknet::{ContractAddress, get_caller_address};
    use starknet::storage::{Map, StorageMapReadAccess, StorageMapWriteAccess};
    use super::IOwnerWriter;
    #[storage]
    pub struct Storage {
        owners: Map<ContractAddress, bool>,
        writers: Map<ContractAddress, bool>,
    }

    #[event]
    #[derive(Drop, Debug, PartialEq, starknet::Event)]
    pub enum Event {}

    #[embeddable_as(IOwnersWriters)]
    impl IOwnerWriterImpl<
        TContractState, +HasComponent<TContractState>,
    > of IOwnerWriter<ComponentState<TContractState>> {
        fn owner(self: @ComponentState<TContractState>, owner: ContractAddress) -> bool {
            self.is_owner(owner)
        }

        fn writer(self: @ComponentState<TContractState>, writer: ContractAddress) -> bool {
            self.is_writer(writer)
        }

        fn grant_owner(ref self: ComponentState<TContractState>, owner: ContractAddress) {
            self.set_owner(owner, true);
        }

        fn revoke_owner(ref self: ComponentState<TContractState>, owner: ContractAddress) {
            self.set_owner(owner, false);
        }

        fn grant_writer(ref self: ComponentState<TContractState>, writer: ContractAddress) {
            self.set_writer(writer, true);
        }

        fn revoke_writer(ref self: ComponentState<TContractState>, writer: ContractAddress) {
            self.set_writer(writer, false);
        }
    }

    pub trait OwnersWriters<TState> {
        fn is_owner(self: @TState, owner: ContractAddress) -> bool;
        fn is_writer(self: @TState, writer: ContractAddress) -> bool;
        fn set_owner(ref self: TState, owner: ContractAddress, is_owner: bool);
        fn set_writer(ref self: TState, writer: ContractAddress, is_writer: bool);
        fn assert_is_owner(self: @TState, owner: ContractAddress);
        fn assert_is_writer(self: @TState, writer: ContractAddress);
        fn caller_is_owner(self: @TState) -> bool;
        fn caller_is_writer(self: @TState) -> bool;
        fn assert_caller_is_owner(self: @TState);
        fn assert_caller_is_writer(self: @TState);
    }

    impl OwnersWritersComponentImpl<
        TContractState, +HasComponent<TContractState>,
    > of OwnersWriters<ComponentState<TContractState>> {
        fn is_owner(self: @ComponentState<TContractState>, owner: ContractAddress) -> bool {
            self.owners.read(owner)
        }

        fn is_writer(self: @ComponentState<TContractState>, writer: ContractAddress) -> bool {
            self.writers.read(writer)
        }

        fn set_owner(
            ref self: ComponentState<TContractState>, owner: ContractAddress, is_owner: bool,
        ) {
            self.owners.write(owner, is_owner);
        }

        fn set_writer(
            ref self: ComponentState<TContractState>, writer: ContractAddress, is_writer: bool,
        ) {
            self.writers.write(writer, is_writer);
        }

        fn assert_is_owner(self: @ComponentState<TContractState>, owner: ContractAddress) {
            assert!(self.is_owner(owner), "User is not an owner");
        }

        fn assert_is_writer(self: @ComponentState<TContractState>, writer: ContractAddress) {
            assert!(self.is_writer(writer), "User is not a writer");
        }

        fn caller_is_owner(self: @ComponentState<TContractState>) -> bool {
            self.is_owner(get_caller_address())
        }

        fn caller_is_writer(self: @ComponentState<TContractState>) -> bool {
            self.is_writer(get_caller_address())
        }

        fn assert_caller_is_owner(self: @ComponentState<TContractState>) {
            assert!(self.is_owner(get_caller_address()), "Caller is not an owner");
        }

        fn assert_caller_is_writer(self: @ComponentState<TContractState>) {
            assert!(self.is_writer(get_caller_address()), "Caller is not a writer");
        }
    }


    impl OwnersWritersConImpl<
        TContractState, +HasComponent<TContractState>, +Drop<TContractState>,
    > of OwnersWriters<TContractState> {
        fn is_owner(self: @TContractState, owner: ContractAddress) -> bool {
            self.get_component().is_owner(owner)
        }

        fn is_writer(self: @TContractState, writer: ContractAddress) -> bool {
            self.get_component().is_writer(writer)
        }

        fn set_owner(ref self: TContractState, owner: ContractAddress, is_owner: bool) {
            let mut component = self.get_component_mut();
            component.set_owner(owner, is_owner);
        }

        fn set_writer(ref self: TContractState, writer: ContractAddress, is_writer: bool) {
            let mut component = self.get_component_mut();
            component.set_writer(writer, is_writer);
        }

        fn assert_is_owner(self: @TContractState, owner: ContractAddress) {
            self.get_component().assert_is_owner(owner);
        }

        fn assert_is_writer(self: @TContractState, writer: ContractAddress) {
            self.get_component().assert_is_writer(writer);
        }

        fn caller_is_owner(self: @TContractState) -> bool {
            self.get_component().caller_is_owner()
        }

        fn caller_is_writer(self: @TContractState) -> bool {
            self.get_component().caller_is_writer()
        }

        fn assert_caller_is_owner(self: @TContractState) {
            self.get_component().assert_caller_is_owner();
        }

        fn assert_caller_is_writer(self: @TContractState) {
            self.get_component().assert_caller_is_writer();
        }
    }
}
