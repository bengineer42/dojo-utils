use starknet::ContractAddress;
use dojo::model::Model;
use tatami_world::{DojoNsModelStorage, DojoStorage};


pub trait RoleTrait<Role> {
    fn parent_roles(self: @Role) -> Array<Role>;
    fn to_felt252(self: @Role) -> felt252;
    fn to_string(self: @Role) -> ByteArray;
}

#[dojo::model]
#[derive(Drop, Serde)]
pub struct Permission {
    #[key]
    requester: ContractAddress,
    #[key]
    role: felt252,
    has: bool,
}

pub trait PermissionStorage<S, Role> {
    fn get_permission(self: @S, requester: ContractAddress, role: Role) -> bool;
    fn set_permission(ref self: S, requester: ContractAddress, role: Role, has: bool);
    fn set_permissions(ref self: S, permissions: Array<Permission>);
}

/// Implementation of the Permissions trait
///
/// Requires that P can be converted from felt252
pub impl PermissionImpl<
    S,
    Role,
    const PERMISSIONS_NAMESPACE_HASH: felt252,
    +RoleTrait<Role>,
    +DojoStorage<S>,
    +Drop<S>,
    +Drop<Role>,
> of PermissionStorage<S, Role> {
    fn get_permission(self: @S, requester: ContractAddress, role: Role) -> bool {
        self
            .read_ns_member(
                PERMISSIONS_NAMESPACE_HASH,
                Model::<Permission>::ptr_from_keys((requester, role.to_felt252())),
                selector!("has"),
            )
    }

    fn set_permission(ref self: S, requester: ContractAddress, role: Role, has: bool) {
        self
            .write_ns_model(
                PERMISSIONS_NAMESPACE_HASH, @Permission { requester, role: role.to_felt252(), has },
            );
    }

    fn set_permissions(ref self: S, permissions: Array<Permission>) {
        let mut array = ArrayTrait::<@Permission>::new();
        for permission in permissions {
            array.append(@permission);
        };
        self.write_ns_models(PERMISSIONS_NAMESPACE_HASH, array.span());
    }
}
