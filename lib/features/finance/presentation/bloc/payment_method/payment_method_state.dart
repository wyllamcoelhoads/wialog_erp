import 'package:equatable/equatable.dart';
import '../../../domain/entities/payment_method_entity.dart';

abstract class PaymentMethodState extends Equatable {
  const PaymentMethodState();
  @override
  List<Object?> get props => [];
}

class PaymentMethodInitial extends PaymentMethodState {}

class PaymentMethodLoading extends PaymentMethodState {}

class PaymentMethodLoaded extends PaymentMethodState {
  final List<PaymentMethodEntity> methods;
  const PaymentMethodLoaded(this.methods);
  @override
  List<Object?> get props => [methods];
}

class PaymentMethodError extends PaymentMethodState {
  final String message;
  const PaymentMethodError(this.message);
  @override
  List<Object?> get props => [message];
}
