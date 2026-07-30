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
    // Busca o usuário batendo e-mail e senha
    const sql =
        'SELECT * FROM users WHERE email = @email AND password = @password';

    final result = await dbConnection.query(sql, {
      'email': email,
      'password': password,
    });

    if (result.isEmpty) {
      return null; // Credenciais inválidas
    }

    return UserModel.fromMap(result.first.toColumnMap());
  }
}
