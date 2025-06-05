use dojo::world::{IWorldDispatcher, WorldStorage, WorldStorageTrait};
use dojo::world::storage::ModelStorageWorldStorageImpl;
use dojo::contract::components::world_provider::world_provider_cpt::{
    WorldProvider, HasComponent as WorldComponent,
};
use dojo::model::{Model, ModelPtr};
use dojo::meta::Introspect;

pub const WORLD_STORAGE_ADDRESS: felt252 =
    0x01704e5494cfadd87ce405d38a662ae6a1d354612ea0ebdc9fefdeb969065774;

pub trait DojoStorage<T> {
    fn storage(self: @T, namespace_hash: felt252) -> WorldStorage;
}


pub impl IWorldDispatcherWorldImpl of DojoStorage<IWorldDispatcher> {
    fn storage(self: @IWorldDispatcher, namespace_hash: felt252) -> WorldStorage {
        WorldStorageTrait::new_from_hash(*self, namespace_hash)
    }
}

pub impl WorldStorageWorldImpl of DojoStorage<WorldStorage> {
    fn storage(self: @WorldStorage, namespace_hash: felt252) -> WorldStorage {
        WorldStorageTrait::new_from_hash(*self.dispatcher, namespace_hash)
    }
}

pub impl ContractStateWorldImpl<
    TState, +Drop<TState>, +WorldComponent<TState>,
> of DojoStorage<TState> {
    fn storage(self: @TState, namespace_hash: felt252) -> WorldStorage {
        WorldStorageTrait::new_from_hash(self.get_component().world_dispatcher(), namespace_hash)
    }
}

#[generate_trait]
pub impl WorldDispatcherImpl<
    TContractState, +WorldComponent<TContractState>,
> of WorldDispatcher<TContractState> {
    fn world_dispatcher(self: @TContractState) -> IWorldDispatcher {
        self.get_component().world_dispatcher()
    }
}

#[generate_trait]
pub impl DojoNsModelStorageImpl<
    S, M, +DojoStorage<S>, +Drop<S>, +Model<M>, +Drop<M>,
> of DojoNsModelStorage<S, M> {
    fn write_ns_model(ref self: S, namespace: felt252, model: @M) {
        let mut storage = self.storage(namespace);
        ModelStorageWorldStorageImpl::<M>::write_model(ref storage, model);
    }
    fn write_ns_models(ref self: S, namespace: felt252, models: Span<@M>) {
        let mut storage = self.storage(namespace);
        ModelStorageWorldStorageImpl::<M>::write_models(ref storage, models);
    }
    fn read_ns_model<K, +Drop<K>, +Serde<K>>(self: @S, namespace: felt252, keys: K) -> M {
        ModelStorageWorldStorageImpl::<M>::read_model(@self.storage(namespace), keys)
    }
    fn read_ns_models<K, +Drop<K>, +Serde<K>>(
        self: @S, namespace: felt252, keys: Span<K>,
    ) -> Array<M> {
        ModelStorageWorldStorageImpl::<M>::read_models(@self.storage(namespace), keys)
    }
    fn erase_ns_model(ref self: S, namespace: felt252, model: @M) {
        let mut storage = self.storage(namespace);
        ModelStorageWorldStorageImpl::<M>::erase_model(ref storage, model);
    }
    fn erase_ns_models(ref self: S, namespace: felt252, models: Span<@M>) {
        let mut storage = self.storage(namespace);
        ModelStorageWorldStorageImpl::<M>::erase_models(ref storage, models);
    }
    fn erase_ns_model_ptr(ref self: S, namespace: felt252, ptr: ModelPtr<M>) {
        let mut storage = self.storage(namespace);
        ModelStorageWorldStorageImpl::<M>::erase_model_ptr(ref storage, ptr);
    }
    fn erase_ns_models_ptrs(ref self: S, namespace: felt252, ptrs: Span<ModelPtr<M>>) {
        let mut storage = self.storage(namespace);
        ModelStorageWorldStorageImpl::<M>::erase_models_ptrs(ref storage, ptrs);
    }
    fn read_ns_member<T, +Serde<T>>(
        self: @S, namespace: felt252, ptr: ModelPtr<M>, field_selector: felt252,
    ) -> T {
        ModelStorageWorldStorageImpl::<
            M,
        >::read_member(@self.storage(namespace), ptr, field_selector)
    }
    fn read_ns_member_of_models<T, +Serde<T>, +Drop<T>>(
        self: @S, namespace: felt252, ptrs: Span<ModelPtr<M>>, field_selector: felt252,
    ) -> Array<T> {
        ModelStorageWorldStorageImpl::<
            M,
        >::read_member_of_models(@self.storage(namespace), ptrs, field_selector)
    }
    fn write_ns_member<T, +Serde<T>, +Drop<T>>(
        ref self: S, namespace: felt252, ptr: ModelPtr<M>, field_selector: felt252, value: T,
    ) {
        let mut storage = self.storage(namespace);
        ModelStorageWorldStorageImpl::<M>::write_member(ref storage, ptr, field_selector, value);
    }
    fn write_ns_member_of_models<T, +Serde<T>, +Drop<T>>(
        ref self: S,
        namespace: felt252,
        ptrs: Span<ModelPtr<M>>,
        field_selector: felt252,
        values: Span<T>,
    ) {
        let mut storage = self.storage(namespace);
        ModelStorageWorldStorageImpl::<
            M,
        >::write_member_of_models(ref storage, ptrs, field_selector, values);
    }
    fn read_ns_schema<T, +Serde<T>, +Introspect<T>>(
        self: @S, namespace: felt252, ptr: ModelPtr<M>,
    ) -> T {
        ModelStorageWorldStorageImpl::<M>::read_schema(@self.storage(namespace), ptr)
    }
    fn read_ns_schemas<T, +Drop<T>, +Serde<T>, +Introspect<T>>(
        self: @S, namespace: felt252, ptrs: Span<ModelPtr<M>>,
    ) -> Array<T> {
        ModelStorageWorldStorageImpl::<M>::read_schemas(@self.storage(namespace), ptrs)
    }
}
