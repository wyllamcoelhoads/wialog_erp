import 'package:wialog_erp/features/role/data/datasources/role_data_source.dart';

import '../../domain/entities/role_entity.dart';
import '../../domain/repositories/role_repository.dart';
import '../models/role_model.dart';

class RoleRepositoryImpl implements RoleRepository {
  final RoleDataSource dataSource;

  RoleRepositoryImpl(this.dataSource);

  @override
  Future<List<RoleEntity>> getRoles({bool includeInactive = false}) async {
    return await dataSource.getRoles(includeInactive: includeInactive);
  }

  @override
  Future<RoleEntity> createRole(RoleEntity role) async {
    return await dataSource.createRole(RoleModel.fromEntity(role));
  }

  @override
  Future<RoleEntity> updateRole(RoleEntity role) async {
    return await dataSource.updateRole(RoleModel.fromEntity(role));
  }

  @override
  Future<void> deleteRole(int id) async {
    await dataSource.deleteRole(id);
  }
}
