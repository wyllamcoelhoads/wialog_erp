import '../entities/role_entity.dart';

abstract class RoleRepository {
  Future<List<RoleEntity>> getRoles({bool includeInactive = false});
  Future<RoleEntity> createRole(RoleEntity role);
  Future<RoleEntity> updateRole(RoleEntity role);
  Future<void> deleteRole(int id);
}
