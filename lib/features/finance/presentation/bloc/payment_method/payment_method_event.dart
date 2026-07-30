import 'package:equatable/equatable.dart';
import '../../../domain/entities/payment_method_entity.dart';

abstract class PaymentMethodEvent extends Equatable {
  const PaymentMethodEvent();
  @override
  List<Object?> get props => [];
}

class LoadPaymentMethods extends PaymentMethodEvent {
  final bool includeInactive;
  const LoadPaymentMethods({this.includeInactive = false});

  @override
  List<Object?> get props => [includeInactive];
}

class AddPaymentMethod extends PaymentMethodEvent {
  final PaymentMethodEntity method;
  const AddPaymentMethod(this.method);
  @override
  List<Object?> get props => [method];
}

class UpdatePaymentMethod extends PaymentMethodEvent {
  final PaymentMethodEntity method;
  const UpdatePaymentMethod(this.method);
  @override
  List<Object?> get props => [method];
}

class DeletePaymentMethod extends PaymentMethodEvent {
  final int id;
  const DeletePaymentMethod(this.id);
  @override
  List<Object?> get props => [id];
}
