import 'package:equatable/equatable.dart';
import '../../../domain/entities/financial_document_entity.dart';

abstract class DocumentState extends Equatable {
  const DocumentState();
  @override
  List<Object> get props => [];
}

class DocumentInitial extends DocumentState {}

class DocumentLoading extends DocumentState {}

class DocumentLoaded extends DocumentState {
  final List<FinancialDocumentEntity> documents;
  const DocumentLoaded(this.documents);
  @override
  List<Object> get props => [documents];
}

class DocumentError extends DocumentState {
  final String message;
  const DocumentError(this.message);
  @override
  List<Object> get props => [message];
}
