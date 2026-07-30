import 'package:wialog_erp/features/finance/domain/entities/payment_method_entity.dart';

abstract class PaymentMethodRepository {
  Future<List<PaymentMethodEntity>> getPaymentMethods({
    bool includeInactive = false,
  });
  Future<PaymentMethodEntity> createPaymentMethod(PaymentMethodEntity method);
  Future<PaymentMethodEntity> updatePaymentMethod(PaymentMethodEntity method);
  Future<void> deletePaymentMethod(int id);
}
