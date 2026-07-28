import 'package:postgres/postgres.dart';

class DatabaseConnection {
  Connection? _connection;

  // Função central para obter a conexão
  Future<Connection> getConnection() async {
    // Se já estiver aberto, reaproveita a mesma conexão
    if (_connection != null && _connection!.isOpen) {
      return _connection!;
    }

    // Tenta abrir uma nova conexão.
    // DICA: No futuro, estes valores virão de um arquivo de configuração local (.env ou JSON)
    _connection = await Connection.open(
      Endpoint(
        host: 'localhost', // Servidor local (sua máquina)
        database: 'wialog_db', // Nome do banco que você vai criar lá no pgAdmin
        username: 'postgres', // Usuário padrão
        password: '123', // Senha padrão de teste (altere para a sua!)
        port: 5432,
      ),
      settings: const ConnectionSettings(
        sslMode: SslMode.disable, // Desativado para desenvolvimento local
      ),
    );

    return _connection!;
  }

  // Um atalho facilitador para não precisarmos chamar getConnection() o tempo todo
  Future<Result> query(String sql, [Map<String, dynamic>? parameters]) async {
    final conn = await getConnection();

    // O pacote postgres novo (v3.0+) usa Sql.named para parâmetros nomeados
    if (parameters != null && parameters.isNotEmpty) {
      return await conn.execute(Sql.named(sql), parameters: parameters);
    } else {
      return await conn.execute(sql);
    }
  }
}
