import '../../domain/entities/payment_method_entity.dart';

class PaymentMethodModel extends PaymentMethodEntity {
  PaymentMethodModel({required super.id, required super.name, super.isActive});

  factory PaymentMethodModel.fromMap(Map<String, dynamic> map) {
    return PaymentMethodModel(
      id: map['id'],
      name: map['name'],
      isActive: map['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'is_active': isActive};
  }

  factory PaymentMethodModel.fromEntity(PaymentMethodEntity entity) {
    return PaymentMethodModel(
      id: entity.id,
      name: entity.name,
      isActive: entity.isActive,
    );
  }
}
