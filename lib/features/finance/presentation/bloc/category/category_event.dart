import 'package:equatable/equatable.dart';
import '../../../domain/entities/category_entity.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();
  @override
  List<Object?> get props => [];
}

class LoadCategories extends CategoryEvent {
  final CategoryType? type;
  const LoadCategories({this.type});

  @override
  List<Object?> get props => [type];
}

class AddCategory extends CategoryEvent {
  final CategoryEntity category;
  const AddCategory(this.category);
  @override
  List<Object> get props => [category];
}

class UpdateCategory extends CategoryEvent {
  final CategoryEntity category;
  const UpdateCategory(this.category);
  @override
  List<Object> get props => [category];
}

class DeleteCategory extends CategoryEvent {
  final int id;
  final CategoryType
  type; // Necessário para recarregar a aba certa após excluir

  const DeleteCategory(this.id, this.type);

  @override
  List<Object> get props => [id, type];
}
