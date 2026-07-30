import 'package:wialog_erp/features/finance/data/models/user_model.dart';

import '../../../../core/database/database_connection.dart';

abstract class AuthDataSource {
  Future<UserModel?> authenticate(String email, String password);
}

class AuthPostgresDataSource implements AuthDataSource {
  final DatabaseConnection dbConnection;

  AuthPostgresDataSource(this.dbConnection);

  @override
  Future<UserModel?> authenticate(String email, String password) async {
    const sql = '''
      SELECT u.*, e.name as employee_name, r.name as role_name 
      FROM users u
      JOIN employees e ON u.employee_id = e.id
      JOIN roles r ON u.role_id = r.id
      WHERE u.email = @email AND u.password = @password
    ''';

    final result = await dbConnection.query(sql, {
      'email': email,
      'password': password,
    });

    if (result.isEmpty) {
      return null;
    }

    return UserModel.fromMap(result.first.toColumnMap());
  }
}
