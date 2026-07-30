import '../../../../core/database/database_connection.dart';
import '../models/employee_model.dart';

abstract class EmployeeDataSource {
  Future<List<EmployeeModel>> getEmployees({bool includeInactive = false});
  Future<EmployeeModel> createEmployee(EmployeeModel employee);
  Future<EmployeeModel> updateEmployee(EmployeeModel employee);
  Future<void> deleteEmployee(int id);
}

class EmployeePostgresDataSource implements EmployeeDataSource {
  final DatabaseConnection dbConnection;
  EmployeePostgresDataSource(this.dbConnection);

  @override
  Future<List<EmployeeModel>> getEmployees({
    bool includeInactive = false,
  }) async {
    String sql = '''
      SELECT e.*, r.name as role_name 
      FROM employees e
      LEFT JOIN roles r ON e.role_id = r.id
      WHERE 1=1
    ''';

    if (!includeInactive) {
      sql += ' AND e.is_active = true';
    }

    sql += ' ORDER BY e.name ASC';

    final result = await dbConnection.query(sql);
    return result
        .map((row) => EmployeeModel.fromMap(row.toColumnMap()))
        .toList();
  }

  @override
  Future<EmployeeModel> createEmployee(EmployeeModel employee) async {
    const sql = '''
      INSERT INTO employees (name, cpf, role_id, license_category, license_expiration, is_active)
      VALUES (@name, @cpf, @role_id, @license_category, @license_expiration, @is_active)
      RETURNING *;
    ''';
    final params = employee.toMap();
    params.remove('id');
    final result = await dbConnection.query(sql, params);
    return EmployeeModel.fromMap(result.first.toColumnMap());
  }

  @override
  Future<EmployeeModel> updateEmployee(EmployeeModel employee) async {
    const sql = '''
      UPDATE employees 
      SET name = @name, cpf = @cpf, role_id = @role_id, 
          license_category = @license_category, license_expiration = @license_expiration, 
          is_active = @is_active
      WHERE id = @id
      RETURNING *;
    ''';
    final result = await dbConnection.query(sql, employee.toMap());
    return EmployeeModel.fromMap(result.first.toColumnMap());
  }

  @override
  Future<void> deleteEmployee(int id) async {
    const sql = 'UPDATE employees SET is_active = false WHERE id = @id';
    await dbConnection.query(sql, {'id': id});
  }
}
