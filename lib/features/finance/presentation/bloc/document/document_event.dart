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
  const LoadDocuments({this.type, this.query});
  @override
  List<Object?> get props => [type, query];
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
