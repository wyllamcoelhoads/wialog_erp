import '../../../../core/database/database_connection.dart';
import '../models/document_model.dart';
import '../../domain/entities/financial_document_entity.dart';

abstract class DocumentDataSource {
  Future<List<DocumentModel>> getDocuments({DocumentType? type, String? query});
  Future<DocumentModel> createDocument(DocumentModel document);
  Future<DocumentModel> updateDocument(DocumentModel document);
  Future<void> deleteDocument(String id);
}

class DocumentPostgresDataSource implements DocumentDataSource {
  final DatabaseConnection dbConnection;
  DocumentPostgresDataSource(this.dbConnection);

  @override
  Future<List<DocumentModel>> getDocuments({
    DocumentType? type,
    String? query,
  }) async {
    // MÁGICA DO SQL: Usamos JOIN para já trazer o nome do parceiro e da categoria!
    String sql = '''
      SELECT d.*, p.name as partner_name, c.name as category_name 
      FROM financial_documents d
      LEFT JOIN partners p ON d.partner_id = p.id
      LEFT JOIN categories c ON d.category_id = c.id
      WHERE d.is_active = true
    ''';
    Map<String, dynamic> params = {};

    if (type != null) {
      sql += " AND d.type = @type";
      params['type'] = type.name;
    }

    if (query != null && query.isNotEmpty) {
      sql += " AND (d.description ILIKE @query OR p.name ILIKE @query)";
      params['query'] = '%$query%';
    }

    sql += " ORDER BY d.due_date ASC"; // Ordena pelo vencimento mais próximo

    final result = await dbConnection.query(sql, params);
    return result
        .map((row) => DocumentModel.fromMap(row.toColumnMap()))
        .toList();
  }

  @override
  Future<DocumentModel> createDocument(DocumentModel doc) async {
    const sql = '''
      INSERT INTO financial_documents 
      (id, description, type, value, balance, issue_date, due_date, payment_date, category_id, partner_id, status, notes, is_active)
      VALUES 
      (@id, @description, @type, @value, @balance, @issue_date, @due_date, @payment_date, @category_id, @partner_id, @status, @notes, @is_active)
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
        category_id = @category_id, partner_id = @partner_id, status = @status, notes = @notes, is_active = @is_active
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
}
