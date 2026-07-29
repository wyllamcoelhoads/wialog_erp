import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/document_repository.dart';
import 'document_event.dart';
import 'document_state.dart';

class DocumentBloc extends Bloc<DocumentEvent, DocumentState> {
  final DocumentRepository repository;

  DocumentBloc(this.repository) : super(DocumentInitial()) {
    // NOVO: Volta a tela para o estado vazio inicial
    on<ClearDocuments>((event, emit) {
      emit(DocumentInitial());
    });

    on<LoadDocuments>((event, emit) async {
      emit(DocumentLoading());
      try {
        final docs = await repository.getDocuments(
          type: event.type,
          query: event.query,
          startDate: event.startDate,
          endDate: event.endDate,
        );
        // MUDANÇA: Agora o BLoC avisa de qual tipo são esses documentos
        emit(DocumentLoaded(docs, event.type!));
      } catch (e) {
        emit(DocumentError(e.toString()));
      }
    });

    on<AddDocument>((event, emit) async {
      emit(DocumentLoading());
      try {
        await repository.createDocument(event.document);
        add(LoadDocuments(type: event.document.type));
      } catch (e) {
        emit(DocumentError(e.toString()));
      }
    });

    on<UpdateDocument>((event, emit) async {
      emit(DocumentLoading());
      try {
        await repository.updateDocument(event.document);
        add(LoadDocuments(type: event.document.type));
      } catch (e) {
        emit(DocumentError(e.toString()));
      }
    });

    on<DeleteDocument>((event, emit) async {
      emit(DocumentLoading());
      try {
        await repository.deleteDocument(event.id);
        add(LoadDocuments(type: event.type));
      } catch (e) {
        emit(DocumentError(e.toString()));
      }
    });
  }
}
