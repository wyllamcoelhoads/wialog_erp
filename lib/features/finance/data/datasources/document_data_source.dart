import '../../../../core/database/database_connection.dart';
import '../models/document_model.dart';
import '../../domain/entities/financial_document_entity.dart';

abstract class DocumentDataSource {
  Future<List<DocumentModel>> getDocuments({
    DocumentType? type,
    String? query,
    DateTime? startDate, // NOVO: Adicionado aqui!
    DateTime? endDate, // NOVO: Adicionado aqui!
  });
  Future<DocumentModel> createDocument(DocumentModel document);
  Future<DocumentModel> updateDocument(DocumentModel document);
  Future<void> deleteDocument(String id);
  // NOVO: Função de Baixa (Liquidação)
  Future<void> settleDocument(
    String id,
    int bankAccountId,
    int paymentMethodId,
    double amount,
    DateTime paymentDate,
  );
}

class DocumentPostgresDataSource implements DocumentDataSource {
  final DatabaseConnection dbConnection;
  DocumentPostgresDataSource(this.dbConnection);

  @override
  Future<List<DocumentModel>> getDocuments({
    DocumentType? type,
    String? query,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    String sql = '''
      SELECT d.*, p.name as partner_name, c.name as category_name,
             b.description as bank_name, pm.name as payment_method_name
      FROM financial_documents d
      LEFT JOIN partners p ON d.partner_id = p.id
      LEFT JOIN categories c ON d.category_id = c.id
      LEFT JOIN bank_accounts b ON d.bank_account_id = b.id
      LEFT JOIN payment_methods pm ON d.payment_method_id = pm.id
      WHERE d.is_active = true
    ''';
    Map<String, dynamic> params = {};

    if (type != null) {
      sql += " AND d.type = @type";
      params['type'] = type.name;
    }

    // Busca exata pelo ID ou busca aproximada pelo nome/descrição
    if (query != null && query.isNotEmpty) {
      sql +=
          " AND (d.id = @queryId OR d.description ILIKE @query OR p.name ILIKE @query)";
      params['queryId'] = query;
      params['query'] = '%$query%';
    }

    // Filtro por Período de Vencimento
    if (startDate != null) {
      sql += " AND d.due_date >= @startDate";
      params['startDate'] = startDate.toIso8601String().split('T')[0];
    }
    if (endDate != null) {
      sql += " AND d.due_date <= @endDate";
      params['endDate'] = endDate.toIso8601String().split('T')[0];
    }

    sql += " ORDER BY d.due_date ASC";

    final result = await dbConnection.query(sql, params);
    return result
        .map((row) => DocumentModel.fromMap(row.toColumnMap()))
        .toList();
  }

  @override
  Future<DocumentModel> createDocument(DocumentModel doc) async {
    const sql = '''
      INSERT INTO financial_documents 
      (id, description, type, value, balance, issue_date, due_date, payment_date, category_id, partner_id, bank_account_id, payment_method_id, status, notes, is_active)
      VALUES 
      (@id, @description, @type, @value, @balance, @issue_date, @due_date, @payment_date, @category_id, @partner_id, @bank_account_id, @payment_method_id, @status, @notes, @is_active)
      RETURNING *;
    ''';
    final result = await dbConnection.query(sql, doc.toMap());
    return DocumentModel.fromMap(result.first.toColumnMap());
  }

  @override
  Future<DocumentModel> updateDocument(DocumentModel doc) async {
    const sql = '''
      UPDATE financial_documents SET 
        description = @description, type = @type, value = @value, balance = @balance, 
        issue_date = @issue_date, due_date = @due_date, payment_date = @payment_date, 
        category_id = @category_id, partner_id = @partner_id, bank_account_id = @bank_account_id, payment_method_id = @payment_method_id,
        status = @status, notes = @notes, is_active = @is_active
      WHERE id = @id
      RETURNING *;
    ''';
    final result = await dbConnection.query(sql, doc.toMap());
    return DocumentModel.fromMap(result.first.toColumnMap());
  }

  @override
  Future<void> deleteDocument(String id) async {
    const sql =
        'UPDATE financial_documents SET is_active = false WHERE id = @id';
    await dbConnection.query(sql, {'id': id});
  }

  // === NOVO: A LÓGICA DE BAIXA DO TÍTULO E ATUALIZAÇÃO DO SALDO ===
  @override
  Future<void> settleDocument(
    String id,
    int bankAccountId,
    int paymentMethodId,
    double amount,
    DateTime paymentDate,
  ) async {
    // 1. Iniciamos uma transação manual. Se algo der erro no meio, ele cancela tudo (Rollback).
    await dbConnection.query('BEGIN');
    try {
      final docResult = await dbConnection.query(
        'SELECT type, status FROM financial_documents WHERE id = @id',
        {'id': id},
      );
      if (docResult.isEmpty) throw Exception('Documento não encontrado.');

      final row = docResult.first.toColumnMap();
      if (row['status'] == 'paid')
        throw Exception('Este documento já consta como pago.');

      final isReceivable = row['type'] == 'receivable';

      // 2. Atualiza o Título (Zera o saldo, muda para 'paid' e vincula banco/moeda)
      await dbConnection.query(
        '''
        UPDATE financial_documents 
        SET status = 'paid', balance = 0, payment_date = @payment_date,
            bank_account_id = @bank_account_id, payment_method_id = @payment_method_id
        WHERE id = @id
      ''',
        {
          'id': id,
          'payment_date': paymentDate.toIso8601String().split('T')[0],
          'bank_account_id': bankAccountId,
          'payment_method_id': paymentMethodId,
        },
      );

      // 3. Atualiza o Saldo da Conta Bancária (+ se for receita, - se for despesa)
      final operator = isReceivable ? '+' : '-';
      await dbConnection.query(
        '''
        UPDATE bank_accounts
        SET current_balance = current_balance $operator @amount
        WHERE id = @bank_id
      ''',
        {'amount': amount, 'bank_id': bankAccountId},
      );

      // 4. Confirma as duas operações no banco
      await dbConnection.query('COMMIT');
    } catch (e) {
      await dbConnection.query('ROLLBACK');
      rethrow; // Repassa o erro para a tela avisar o usuário
    }
  }
}
