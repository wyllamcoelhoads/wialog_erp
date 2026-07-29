import 'package:wialog_erp/features/finance/data/datasources/payment_method_data_source.dart';

import '../../domain/entities/payment_method_entity.dart';
import '../../domain/repositories/payment_method_repository.dart';
import '../models/payment_method_model.dart';

class PaymentMethodRepositoryImpl implements PaymentMethodRepository {
  final PaymentMethodDataSource dataSource;

  PaymentMethodRepositoryImpl(this.dataSource);

  @override
  Future<List<PaymentMethodEntity>> getPaymentMethods({
    bool includeInactive = false,
  }) async {
    return await dataSource.getPaymentMethods(includeInactive: includeInactive);
  }

  @override
  Future<PaymentMethodEntity> createPaymentMethod(
    PaymentMethodEntity method,
  ) async {
    final model = PaymentMethodModel.fromEntity(method);
    return await dataSource.createPaymentMethod(model);
  }

  @override
  Future<PaymentMethodEntity> updatePaymentMethod(
    PaymentMethodEntity method,
  ) async {
    final model = PaymentMethodModel.fromEntity(method);
    return await dataSource.updatePaymentMethod(model);
  }

  @override
  Future<void> deletePaymentMethod(int id) async {
    await dataSource.deletePaymentMethod(id);
  }
}
