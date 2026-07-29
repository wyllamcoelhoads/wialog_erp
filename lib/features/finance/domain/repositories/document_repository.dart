import '../entities/financial_document_entity.dart';

abstract class DocumentRepository {
  Future<List<FinancialDocumentEntity>> getDocuments({
    DocumentType? type,
    String? query,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<FinancialDocumentEntity> createDocument(
    FinancialDocumentEntity document,
  );
  Future<FinancialDocumentEntity> updateDocument(
    FinancialDocumentEntity document,
  );
  Future<void> deleteDocument(String id);
}
