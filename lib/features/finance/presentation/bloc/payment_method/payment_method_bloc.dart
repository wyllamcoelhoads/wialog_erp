import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/payment_method_repository.dart';
import 'payment_method_event.dart';
import 'payment_method_state.dart';

class PaymentMethodBloc extends Bloc<PaymentMethodEvent, PaymentMethodState> {
  final PaymentMethodRepository repository;

  // Guarda a preferência do usuário (se está vendo as inativas ou não)
  bool _lastIncludeInactive = false;

  PaymentMethodBloc(this.repository) : super(PaymentMethodInitial()) {
    // Buscar
    on<LoadPaymentMethods>((event, emit) async {
      emit(PaymentMethodLoading());
      _lastIncludeInactive = event.includeInactive;
      try {
        final methods = await repository.getPaymentMethods(
          includeInactive: event.includeInactive,
        );
        emit(PaymentMethodLoaded(methods));
      } catch (e) {
        emit(PaymentMethodError('Erro ao buscar formas de pagamento: $e'));
      }
    });

    // Criar
    on<AddPaymentMethod>((event, emit) async {
      emit(PaymentMethodLoading());
      try {
        await repository.createPaymentMethod(event.method);
        add(LoadPaymentMethods(includeInactive: _lastIncludeInactive));
      } catch (e) {
        emit(PaymentMethodError('Erro ao salvar: $e'));
      }
    });

    // Atualizar
    on<UpdatePaymentMethod>((event, emit) async {
      emit(PaymentMethodLoading());
      try {
        await repository.updatePaymentMethod(event.method);
        add(LoadPaymentMethods(includeInactive: _lastIncludeInactive));
      } catch (e) {
        emit(PaymentMethodError('Erro ao atualizar: $e'));
      }
    });

    // Inativar
    on<DeletePaymentMethod>((event, emit) async {
      emit(PaymentMethodLoading());
      try {
        await repository.deletePaymentMethod(event.id);
        add(LoadPaymentMethods(includeInactive: _lastIncludeInactive));
      } catch (e) {
        emit(PaymentMethodError('Erro ao excluir: $e'));
      }
    });
  }
}
