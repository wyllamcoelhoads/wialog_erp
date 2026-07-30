import '../../../../core/database/database_connection.dart';
import '../models/payment_method_model.dart';

abstract class PaymentMethodDataSource {
  Future<List<PaymentMethodModel>> getPaymentMethods({
    bool includeInactive = false,
  });
  Future<PaymentMethodModel> createPaymentMethod(PaymentMethodModel method);
  Future<PaymentMethodModel> updatePaymentMethod(PaymentMethodModel method);
  Future<void> deletePaymentMethod(int id);
}

class PaymentMethodPostgresDataSource implements PaymentMethodDataSource {
  final DatabaseConnection dbConnection;

  PaymentMethodPostgresDataSource(this.dbConnection);

  @override
  Future<List<PaymentMethodModel>> getPaymentMethods({
    bool includeInactive = false,
  }) async {
    String sql = 'SELECT * FROM payment_methods';

    if (!includeInactive) {
      sql += ' WHERE is_active = true';
    }

    sql += ' ORDER BY name ASC';

    final result = await dbConnection.query(sql);
    return result
        .map((row) => PaymentMethodModel.fromMap(row.toColumnMap()))
        .toList();
  }

  @override
  Future<PaymentMethodModel> createPaymentMethod(
    PaymentMethodModel method,
  ) async {
    const sql = '''
      INSERT INTO payment_methods (name, is_active)
      VALUES (@name, @is_active)
      RETURNING *;
    ''';

    final params = method.toMap();
    params.remove('id'); // Banco gera automaticamente

    final result = await dbConnection.query(sql, params);
    return PaymentMethodModel.fromMap(result.first.toColumnMap());
  }

  @override
  Future<PaymentMethodModel> updatePaymentMethod(
    PaymentMethodModel method,
  ) async {
    const sql = '''
      UPDATE payment_methods 
      SET name = @name, is_active = @is_active
      WHERE id = @id
      RETURNING *;
    ''';
    final result = await dbConnection.query(sql, method.toMap());
    return PaymentMethodModel.fromMap(result.first.toColumnMap());
  }

  @override
  Future<void> deletePaymentMethod(int id) async {
    const sql = 'UPDATE payment_methods SET is_active = false WHERE id = @id';
    await dbConnection.query(sql, {'id': id});
  }
}
