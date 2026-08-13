import 'package:equatable/equatable.dart';
import '../../../domain/entities/financial_document_entity.dart';

abstract class DocumentEvent extends Equatable {
  const DocumentEvent();
  @override
  List<Object?> get props => [];
}

class LoadDocuments extends DocumentEvent {
  final DocumentType? type;
  final String? query;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool filterByIssueDate;
  final bool isOverdue;

  const LoadDocuments({
    this.type,
    this.query,
    this.startDate,
    this.endDate,
    this.filterByIssueDate = false,
    this.isOverdue = false,
  });

  @override
  List<Object?> get props => [
    type,
    query,
    startDate,
    endDate,
    filterByIssueDate,
    isOverdue,
  ];
}

class AddDocument extends DocumentEvent {
  final FinancialDocumentEntity document;
  const AddDocument(this.document);
  @override
  List<Object?> get props => [document];
}

class UpdateDocument extends DocumentEvent {
  final FinancialDocumentEntity document;
  const UpdateDocument(this.document);
  @override
  List<Object?> get props => [document];
}

class DeleteDocument extends DocumentEvent {
  final String id;
  final DocumentType type;
  const DeleteDocument(this.id, this.type);
  @override
  List<Object?> get props => [id, type];
}

class SettleDocument extends DocumentEvent {
  final String documentId;
  final DocumentType type;
  final int bankAccountId;
  final int paymentMethodId;
  final double amount;
  final DateTime paymentDate;

  const SettleDocument({
    required this.documentId,
    required this.type,
    required this.bankAccountId,
    required this.paymentMethodId,
    required this.amount,
    required this.paymentDate,
  });

  @override
  List<Object?> get props => [
    documentId,
    type,
    bankAccountId,
    paymentMethodId,
    amount,
    paymentDate,
  ];
}

class ClearDocuments extends DocumentEvent {}
