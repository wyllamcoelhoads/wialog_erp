import '../../../../core/database/database_connection.dart';
import '../models/role_model.dart';

abstract class RoleDataSource {
  Future<List<RoleModel>> getRoles({bool includeInactive = false});
  Future<RoleModel> createRole(RoleModel role);
  Future<RoleModel> updateRole(RoleModel role);
  Future<void> deleteRole(int id);
}

class RolePostgresDataSource implements RoleDataSource {
  final DatabaseConnection dbConnection;
  RolePostgresDataSource(this.dbConnection);

  @override
  Future<List<RoleModel>> getRoles({bool includeInactive = false}) async {
    String sql = 'SELECT * FROM roles WHERE 1=1';

    if (!includeInactive) {
      sql += ' AND is_active = true';
    }

    sql += ' ORDER BY name ASC';

    final result = await dbConnection.query(sql);
    return result.map((row) => RoleModel.fromMap(row.toColumnMap())).toList();
  }

  @override
  Future<RoleModel> createRole(RoleModel role) async {
    const sql = '''
      INSERT INTO roles (name, description, is_active)
      VALUES (@name, @description, @is_active)
      RETURNING *;
    ''';
    final params = role.toMap();
    params.remove('id');
    final result = await dbConnection.query(sql, params);
    return RoleModel.fromMap(result.first.toColumnMap());
  }

  @override
  Future<RoleModel> updateRole(RoleModel role) async {
    const sql = '''
      UPDATE roles 
      SET name = @name, description = @description, is_active = @is_active
      WHERE id = @id
      RETURNING *;
    ''';
    final result = await dbConnection.query(sql, role.toMap());
    return RoleModel.fromMap(result.first.toColumnMap());
  }

  @override
  Future<void> deleteRole(int id) async {
    const sql = 'UPDATE roles SET is_active = false WHERE id = @id';
    await dbConnection.query(sql, {'id': id});
  }
}
