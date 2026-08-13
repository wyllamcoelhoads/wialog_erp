import 'package:wialog_erp/features/finance/SettlementEntity/domain/entities/settlement_entity.dart';

import '../entities/financial_document_entity.dart';

abstract class DocumentRepository {
  Future<List<FinancialDocumentEntity>> getDocuments({
    DocumentType? type,
    String? query,
    DateTime? startDate,
    DateTime? endDate,
    bool filterByIssueDate = false,
    bool isOverdue = false,
  });
  Future<FinancialDocumentEntity> createDocument(
    FinancialDocumentEntity document,
  );
  Future<FinancialDocumentEntity> updateDocument(
    FinancialDocumentEntity document,
  );
  Future<void> deleteDocument(String id);
  Future<void> settleDocument(
    String id,
    int bankAccountId,
    int paymentMethodId,
    double amount,
    DateTime paymentDate,
  );
  Future<List<SettlementEntity>> getSettlements(String documentId);
}
