import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_datasource.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryDataSource dataSource;

  CategoryRepositoryImpl(this.dataSource);

  @override
  Future<List<CategoryEntity>> getCategories({CategoryType? type}) async {
    return await dataSource.getCategories(type: type);
  }

  @override
  Future<CategoryEntity> createCategory(CategoryEntity category) async {
    final model = CategoryModel.fromEntity(category);
    return await dataSource.createCategory(model);
  }

  @override
  Future<CategoryEntity> updateCategory(CategoryEntity category) async {
    final model = CategoryModel.fromEntity(category);
    return await dataSource.updateCategory(model);
  }

  @override
  Future<void> deleteCategory(int id) async {
    await dataSource.deleteCategory(id);
  }
}
