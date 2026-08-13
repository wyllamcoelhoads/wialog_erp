import '../../../../core/database/database_connection.dart';
import '../models/user_model.dart';

abstract class UserDataSource {
  Future<List<UserModel>> getUsers({bool includeInactive = false});
  Future<UserModel> createUser(UserModel user);
  Future<UserModel> updateUser(UserModel user);
  Future<void> deleteUser(int id);
}

class UserPostgresDataSource implements UserDataSource {
  final DatabaseConnection dbConnection;
  UserPostgresDataSource(this.dbConnection);

  @override
  Future<List<UserModel>> getUsers({bool includeInactive = false}) async {
    String sql = '''
      SELECT u.*, e.name as employee_name, r.name as role_name, r.permissions as role_permissions 
      FROM users u
      JOIN employees e ON u.employee_id = e.id
      JOIN roles r ON u.role_id = r.id
      WHERE 1=1
    ''';

    if (!includeInactive) sql += ' AND u.is_active = true';
    sql += ' ORDER BY e.name ASC';

    final result = await dbConnection.query(sql);
    return result.map((row) => UserModel.fromMap(row.toColumnMap())).toList();
  }

  @override
  Future<UserModel> createUser(UserModel user) async {
    const sql = '''
      INSERT INTO users (employee_id, email, password, role_id, theme, custom_permissions, is_active)
      VALUES (@employee_id, @email, @password, @role_id, @theme, @custom_permissions, @is_active)
      RETURNING *;
    ''';
    final params = {
      'id': user.id,
      'email': user.email,
      'password': user.password,
      'role_id': user.roleId,
      'theme': user.theme,
      'custom_permissions': user.customPermissions,
      'is_active': user.isActive,
    };
    final result = await dbConnection.query(sql, params);
    return UserModel.fromMap(result.first.toColumnMap());
  }

  @override
  Future<UserModel> updateUser(UserModel user) async {
    const sql = '''
      UPDATE users 
      SET email = @email, password = @password, role_id = @role_id, is_active = @is_active, theme = @theme, custom_permissions = @custom_permissions
      WHERE id = @id
      RETURNING *;
    ''';

    // Pegamos os dados do Model
    final params = {
      'id': user.id,
      'email': user.email,
      'password': user.password,
      'role_id': user.roleId,
      'theme': user.theme,
      'custom_permissions': user.customPermissions,
      'is_active': user.isActive,
    };
    final result = await dbConnection.query(sql, params);
    return UserModel.fromMap(result.first.toColumnMap());
  }

  @override
  Future<void> deleteUser(int id) async {
    await dbConnection.query(
      'UPDATE users SET is_active = false WHERE id = @id',
      {'id': id},
    );
  }
}
