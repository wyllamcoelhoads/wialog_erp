import 'package:wialog_erp/features/finance/SettlementEntity/domain/entities/settlement_entity.dart';
import 'package:wialog_erp/features/finance/data/datasources/document_data_source.dart';

import '../../domain/entities/financial_document_entity.dart';
import '../../domain/repositories/document_repository.dart';
import '../models/document_model.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  final DocumentDataSource dataSource;
  DocumentRepositoryImpl(this.dataSource);

  @override
  Future<List<FinancialDocumentEntity>> getDocuments({
    DocumentType? type,
    String? query,
    DateTime? startDate,
    DateTime? endDate,
    bool filterByIssueDate = false,
    bool isOverdue = false,
  }) async {
    return await dataSource.getDocuments(
      type: type,
      query: query,
      startDate: startDate,
      endDate: endDate,
      filterByIssueDate: filterByIssueDate,
      isOverdue: isOverdue,
    );
  }

  @override
  Future<FinancialDocumentEntity> createDocument(
    FinancialDocumentEntity document,
  ) async {
    return await dataSource.createDocument(DocumentModel.fromEntity(document));
  }

  @override
  Future<FinancialDocumentEntity> updateDocument(
    FinancialDocumentEntity document,
  ) async {
    return await dataSource.updateDocument(DocumentModel.fromEntity(document));
  }

  @override
  Future<void> deleteDocument(String id) async {
    await dataSource.deleteDocument(id);
  }

  @override
  Future<void> settleDocument(
    String id,
    int bankAccountId,
    int paymentMethodId,
    double amount,
    DateTime paymentDate,
  ) async {
    await dataSource.settleDocument(
      id,
      bankAccountId,
      paymentMethodId,
      amount,
      paymentDate,
    );
  }

  @override
  Future<List<SettlementEntity>> getSettlements(String documentId) async {
    return await dataSource.getSettlements(documentId);
  }
}
