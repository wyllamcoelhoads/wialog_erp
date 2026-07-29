import 'package:wialog_erp/features/finance/domain/entities/category_entity.dart';

import '../../../../core/database/database_connection.dart';
import '../models/category_model.dart';

abstract class CategoryDataSource {
  Future<List<CategoryModel>> getCategories({CategoryType? type});
  Future<CategoryModel> createCategory(CategoryModel category);
  Future<CategoryModel> updateCategory(CategoryModel category);
  Future<void> deleteCategory(int id);
}

class CategoryPostgresDataSource implements CategoryDataSource {
  final DatabaseConnection dbConnection;
  CategoryPostgresDataSource(this.dbConnection);

  @override
  Future<List<CategoryModel>> getCategories({CategoryType? type}) async {
    // MUDANÇA: Agora lemos da tabela "categories"
    String sql = 'SELECT * FROM categories WHERE is_active = true';
    Map<String, dynamic> params = {};

    // Filtra pelo tipo que a tela pedir
    if (type != null) {
      sql += ' AND type = @type';
      params['type'] = type.name;
    }

    sql += ' ORDER BY name ASC';

    final result = await dbConnection.query(sql, params);
    return result
        .map((row) => CategoryModel.fromMap(row.toColumnMap()))
        .toList();
  }

  @override
  Future<CategoryModel> createCategory(CategoryModel category) async {
    const sql = '''
      INSERT INTO categories (name, type, is_active)
      VALUES (@name, @type, @is_active)
      RETURNING *;
    ''';
    final result = await dbConnection.query(sql, category.toMap());
    return CategoryModel.fromMap(result.first.toColumnMap());
  }

  @override
  Future<CategoryModel> updateCategory(CategoryModel category) async {
    const sql = '''
      UPDATE categories 
      SET name = @name, type = @type, is_active = @is_active
      WHERE id = @id
      RETURNING *;
    ''';
    final result = await dbConnection.query(sql, category.toMap());
    return CategoryModel.fromMap(result.first.toColumnMap());
  }

  @override
  Future<void> deleteCategory(int id) async {
    const sql = 'UPDATE categories SET is_active = false WHERE id = @id';
    await dbConnection.query(sql, {'id': id});
  }
}
