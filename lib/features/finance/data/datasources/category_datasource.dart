import '../../../../core/database/database_connection.dart';
import '../models/category_model.dart';

abstract class CategoryDataSource {
  Future<List<CategoryModel>> getCategories();
}

class CategoryPostgresDataSource implements CategoryDataSource {
  final DatabaseConnection dbConnection;
  CategoryPostgresDataSource(this.dbConnection);

  @override
  Future<List<CategoryModel>> getCategories() async {
    const sql =
        'SELECT * FROM supplier_categories WHERE is_active = true ORDER BY name ASC';
    final result = await dbConnection.query(sql);
    return result
        .map((row) => CategoryModel.fromMap(row.toColumnMap()))
        .toList();
  }
}
