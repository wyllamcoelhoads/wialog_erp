import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/category_repository.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository repository;

  //Guardar a preferencia do usuário (se está vendo as inativas ou não)
  bool _lastIncludeInactive = false;

  CategoryBloc(this.repository) : super(CategoryInitial()) {
    on<LoadCategories>((event, emit) async {
      emit(CategoryLoading());
      _lastIncludeInactive = event
          .includeInactive; // salva o stado do filtro para recarregar a tela corretamente após salvar/excluir
      try {
        final list = await repository.getCategories(
          type: event.type,
          includeInactive: event.includeInactive,
        );
        emit(CategoryLoaded(list));
      } catch (e) {
        emit(CategoryError(e.toString()));
      }
    });

    on<AddCategory>((event, emit) async {
      emit(CategoryLoading());
      try {
        await repository.createCategory(event.category);
        add(
          LoadCategories(
            type: event.category.type,
            includeInactive: _lastIncludeInactive,
          ),
        ); // Recarrega a aba correta
      } catch (e) {
        emit(CategoryError(e.toString()));
      }
    });

    on<UpdateCategory>((event, emit) async {
      emit(CategoryLoading());
      try {
        await repository.updateCategory(event.category);
        add(
          LoadCategories(
            type: event.category.type,
            includeInactive: _lastIncludeInactive,
          ),
        ); // Recarrega a aba correta
      } catch (e) {
        emit(CategoryError(e.toString()));
      }
    });

    on<DeleteCategory>((event, emit) async {
      emit(CategoryLoading());
      try {
        await repository.deleteCategory(event.id);
        add(
          LoadCategories(
            type: event.type,
            includeInactive: _lastIncludeInactive,
          ),
        ); // Recarrega a aba correta
      } catch (e) {
        emit(CategoryError(e.toString()));
      }
    });
  }
}
