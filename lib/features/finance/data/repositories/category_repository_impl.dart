import 'package:wialog_erp/features/finance/data/datasources/category_datasource.dart';
import 'package:wialog_erp/features/finance/domain/entities/category_entity.dart';
import 'package:wialog_erp/features/finance/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryDataSource dataSource;

  CategoryRepositoryImpl(this.dataSource);

  @override
  Future<List<CategoryEntity>> getCategories() async {
    // Como CategoryModel estende CategoryEntity, podemos retornar a lista diretamente.
    // Isso é o poder do polimorfismo na Clean Architecture.
    return await dataSource.getCategories();
  }
}
