import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/document_repository.dart';
import 'document_event.dart';
import 'document_state.dart';

class DocumentBloc extends Bloc<DocumentEvent, DocumentState> {
  final DocumentRepository repository;

  DocumentBloc(this.repository) : super(DocumentInitial()) {
    on<LoadDocuments>(_onLoadDocuments);
    on<AddDocument>(_onAddDocument);
    on<UpdateDocument>(_onUpdateDocument);
    on<DeleteDocument>(_onDeleteDocument);
    on<SettleDocument>(_onSettleDocument);
    on<ClearDocuments>(
      (event, emit) => emit(DocumentInitial()),
    ); // Garante o reset da tela
  }

  Future<void> _onLoadDocuments(
    LoadDocuments event,
    Emitter<DocumentState> emit,
  ) async {
    emit(DocumentLoading());
    try {
      final documents = await repository.getDocuments(
        type: event.type,
        query: event.query,
        startDate: event.startDate,
        endDate: event.endDate,
        filterByIssueDate: event.filterByIssueDate,
        isOverdue: event.isOverdue,
      );
      // 👇 CORREÇÃO: Enviando os argumentos na posição correta (sem nomeá-los)
      emit(DocumentLoaded(documents, event.type!));
    } catch (e) {
      emit(DocumentError('Erro ao carregar documentos: $e'));
    }
  }

  Future<void> _onAddDocument(
    AddDocument event,
    Emitter<DocumentState> emit,
  ) async {
    emit(DocumentLoading());
    try {
      await repository.createDocument(event.document);
      final documents = await repository.getDocuments(
        type: event.document.type,
      );
      // 👇 CORREÇÃO: Argumentos posicionais
      emit(DocumentLoaded(documents, event.document.type));
    } catch (e) {
      emit(DocumentError('Erro ao adicionar documento: $e'));
    }
  }

  Future<void> _onUpdateDocument(
    UpdateDocument event,
    Emitter<DocumentState> emit,
  ) async {
    emit(DocumentLoading());
    try {
      await repository.updateDocument(event.document);
      final documents = await repository.getDocuments(
        type: event.document.type,
      );
      // 👇 CORREÇÃO: Argumentos posicionais
      emit(DocumentLoaded(documents, event.document.type));
    } catch (e) {
      emit(DocumentError('Erro ao atualizar documento: $e'));
    }
  }

  Future<void> _onDeleteDocument(
    DeleteDocument event,
    Emitter<DocumentState> emit,
  ) async {
    emit(DocumentLoading());
    try {
      await repository.deleteDocument(event.id);
      emit(DocumentInitial());
    } catch (e) {
      emit(DocumentError('Erro ao excluir documento: $e'));
    }
  }

  Future<void> _onSettleDocument(
    SettleDocument event,
    Emitter<DocumentState> emit,
  ) async {
    emit(DocumentLoading());
    try {
      // 👇 CORREÇÃO: Função apenas executa a baixa no banco (não retorna um novo documento)
      await repository.settleDocument(
        event.documentId,
        event.bankAccountId,
        event.paymentMethodId,
        event.amount,
        event.paymentDate,
      );

      // Recarrega a lista para mostrar o novo status e zerar o painel da esquerda
      final documents = await repository.getDocuments(type: event.type);

      // 👇 CORREÇÃO: Argumentos posicionais
      emit(DocumentLoaded(documents, event.type));
    } catch (e) {
      emit(DocumentError('Erro ao processar baixa do documento: $e'));
    }
  }
}
