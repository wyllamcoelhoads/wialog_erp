import '../entities/category_entity.dart';

abstract class CategoryRepository {
  Future<List<CategoryEntity>> getCategories({
    CategoryType? type,
    bool includeInactive = false,
  }); // MODIFICADO
  Future<CategoryEntity> createCategory(CategoryEntity category);
  Future<CategoryEntity> updateCategory(CategoryEntity category);
  Future<void> deleteCategory(int id);
}
