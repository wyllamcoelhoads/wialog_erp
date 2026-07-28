import 'package:postgres/postgres.dart';

class DatabaseConnection {
  Connection? _connection;

  Future<Connection> getConnection() async {
    if (_connection != null && _connection!.isOpen) {
      return _connection!;
    }

    try {
      _connection = await Connection.open(
        Endpoint(
          // 👇 MUDANÇA CRUCIAL: Usar o IP direto evita erros de IPv6 no Windows!
          host: '127.0.0.1',
          database: 'postgres',
          username: 'postgres',

          // Confirme se a sua senha do postgres é esta. Se não tiver senha, deixe ''
          password: '123',

          port: 5432,
        ),
        settings: const ConnectionSettings(
          sslMode: SslMode.disable, // Obrigatório para banco local
        ),
      );

      print('✅ SUCESSO: O Flutter conseguiu entrar no PostgreSQL!');
      return _connection!;
    } catch (e) {
      print('❌ ERRO AO CONECTAR NO BANCO DE DADOS: $e');
      rethrow;
    }
  }

  Future<Result> query(String sql, [Map<String, dynamic>? parameters]) async {
    final conn = await getConnection();

    if (parameters != null && parameters.isNotEmpty) {
      return await conn.execute(Sql.named(sql), parameters: parameters);
    } else {
      return await conn.execute(sql);
    }
  }
}
