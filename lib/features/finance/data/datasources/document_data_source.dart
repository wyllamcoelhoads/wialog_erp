import 'package:wialog_erp/features/finance/SettlementEntity/data/models/settlement_model.dart';

import '../../../../core/database/database_connection.dart';
import '../models/document_model.dart';
import '../../domain/entities/financial_document_entity.dart';

abstract class DocumentDataSource {
  Future<List<DocumentModel>> getDocuments({
    DocumentType? type,
    String? query,
    DateTime? startDate,
    DateTime? endDate,
    bool filterByIssueDate = false, // NOVO: Filtro de Emissão
    bool isOverdue = false, // NOVO: Apenas Vencidos
  });
  Future<DocumentModel> createDocument(DocumentModel document);
  Future<DocumentModel> updateDocument(DocumentModel document);
  Future<void> deleteDocument(String id);
  Future<void> settleDocument(
    String id,
    int bankAccountId,
    int paymentMethodId,
    double amount,
    DateTime paymentDate,
  );

  Future<List<SettlementModel>> getSettlements(String documentId);
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
    bool filterByIssueDate = false,
    bool isOverdue = false,
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

    // Busca exata pelo ID ou aproximada pelo nome/CPF/CNPJ do parceiro
    if (query != null && query.isNotEmpty) {
      sql +=
          " AND (d.id = @queryId OR d.description ILIKE @query OR p.name ILIKE @query OR p.document ILIKE @query)";
      params['queryId'] = query;
      params['query'] = '%$query%';
    }

    // Filtro Flexível: Data de Vencimento OU Data de Emissão
    String dateField = filterByIssueDate ? 'd.issue_date' : 'd.due_date';

    if (startDate != null) {
      sql += " AND $dateField >= @startDate";
      params['startDate'] = startDate.toIso8601String().split('T')[0];
    }
    if (endDate != null) {
      sql += " AND $dateField <= @endDate";
      params['endDate'] = endDate.toIso8601String().split('T')[0];
    }

    // Flag: Apenas Títulos Vencidos
    if (isOverdue) {
      sql +=
          " AND d.due_date < CURRENT_DATE AND d.status != 'paid' AND d.status != 'canceled'";
    }

    // Limite de segurança de 200 registros para evitar quebra de memória caso pesquise "Todos"
    sql += " ORDER BY d.due_date ASC LIMIT 200";

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

  @override
  Future<void> settleDocument(
    String id,
    int bankAccountId,
    int paymentMethodId,
    double amount,
    DateTime paymentDate,
  ) async {
    await dbConnection.query('BEGIN');
    try {
      final docResult = await dbConnection.query(
        'SELECT type, status, balance FROM financial_documents WHERE id = @id',
        {'id': id},
      );
      if (docResult.isEmpty) throw Exception('Documento não encontrado.');

      final row = docResult.first.toColumnMap();
      if (row['status'] == 'paid') {
        throw Exception('Este documento já consta como pago totalmente.');
      }

      final isReceivable = row['type'] == 'receivable';
      final currentBalance = double.parse(row['balance'].toString());

      // 1. Grava no Histórico ANTES de mudar o saldo
      await dbConnection.query(
        '''
        INSERT INTO financial_settlements (document_id, amount, payment_date, bank_account_id, payment_method_id)
        VALUES (@doc_id, @amount, @date, @bank, @method)
      ''',
        {
          'doc_id': id,
          'amount': amount,
          'date': paymentDate.toIso8601String().split('T')[0],
          'bank': bankAccountId,
          'method': paymentMethodId,
        },
      );

      // 2. Calcula Novo Saldo
      double newBalance = currentBalance - amount;
      String newStatus = 'partial';
      if (newBalance <= 0) {
        newBalance = 0.0;
        newStatus = 'paid';
      }

      // 3. Atualiza a duplicata
      await dbConnection.query(
        '''
        UPDATE financial_documents 
        SET status = @status, balance = @balance, payment_date = @payment_date,
            bank_account_id = @bank_account_id, payment_method_id = @payment_method_id
        WHERE id = @id
      ''',
        {
          'id': id,
          'status': newStatus,
          'balance': newBalance,
          'payment_date': paymentDate.toIso8601String().split('T')[0],
          'bank_account_id': bankAccountId,
          'payment_method_id': paymentMethodId,
        },
      );

      // 4. Atualiza o Banco
      final operator = isReceivable ? '+' : '-';
      await dbConnection.query(
        '''
        UPDATE bank_accounts
        SET current_balance = current_balance $operator @amount
        WHERE id = @bank_id
      ''',
        {'amount': amount, 'bank_id': bankAccountId},
      );

      await dbConnection.query('COMMIT');
    } catch (e) {
      await dbConnection.query('ROLLBACK');
      rethrow;
    }
  }

  @override
  Future<List<SettlementModel>> getSettlements(String documentId) async {
    const sql = '''
      SELECT s.*, b.description as bank_name, pm.name as method_name
      FROM financial_settlements s
      JOIN bank_accounts b ON s.bank_account_id = b.id
      JOIN payment_methods pm ON s.payment_method_id = pm.id
      WHERE s.document_id = @docId
      ORDER BY s.created_at DESC
    ''';
    final result = await dbConnection.query(sql, {'docId': documentId});
    return result
        .map((row) => SettlementModel.fromMap(row.toColumnMap()))
        .toList();
  }
}
