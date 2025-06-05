use starknet::{ContractAddress, get_caller_address};

use tatami_world::DojoStorage;

use super::{PermissionImpl, RoleTrait};


/// Trait implementation for checking various permission levels
#[generate_trait]
pub impl PermissionsImpl<
    T,
    Role,
    const PERMISSIONS_NAMESPACE_HASH: felt252,
    const ADMIN_ROLE: Role,
    +RoleTrait<Role>,
    +DojoStorage<T>,
    +Drop<T>,
    +Drop<Role>,
    +Copy<Role>,
> of Permissions<T, Role> {
    fn has_admin_permission(self: @T, requester: ContractAddress) -> bool {
        PermissionImpl::<
            T, Role, PERMISSIONS_NAMESPACE_HASH,
        >::get_permission(self, requester, ADMIN_ROLE)
    }

    fn has_role_permission(self: @T, requester: ContractAddress, role: Role) -> bool {
        PermissionImpl::<T, Role, PERMISSIONS_NAMESPACE_HASH>::get_permission(self, requester, role)
    }

    fn has_a_role_permission(self: @T, requester: ContractAddress, mut roles: Array<Role>) -> bool {
        loop {
            match roles.pop_front() {
                Option::Some(role) => {
                    if Self::has_role_permission(self, requester, role) {
                        break true;
                    }
                },
                Option::None => { break false; },
            }
        }
    }

    fn has_parent_role_permission(self: @T, requester: ContractAddress, role: Role) -> bool {
        Self::has_a_role_permission(self, requester, role.parent_roles())
    }

    fn has_permission(self: @T, requester: ContractAddress, role: Role) -> bool {
        Self::has_role_permission(self, requester, role)
            || Self::has_parent_role_permission(self, requester, role)
    }


    fn caller_has_permission(self: @T, role: Role) -> bool {
        Self::has_permission(self, get_caller_address(), role)
    }

    fn assert_has_permission(self: @T, requester: ContractAddress, role: Role) {
        if !Self::has_permission(self, requester, role) {
            panic!("User does not have {} permission", role.to_string());
        }
    }

    fn assert_caller_has_permission(self: @T, role: Role) {
        if !Self::caller_has_permission(self, role) {
            panic!("Caller does not have {} permission", role.to_string());
        }
    }

    fn assert_caller_is_admin(self: @T) {
        Self::assert_caller_has_permission(self, ADMIN_ROLE);
    }
}
