import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wialog_erp/features/finance/domain/repositories/partner_repository.dart';
import 'partner_event.dart';
import 'partner_state.dart';

class PartnerBloc extends Bloc<PartnerEvent, PartnerState> {
  final PartnerRepository repository;

  PartnerBloc(this.repository) : super(PartnerInitial()) {
    on<LoadPartners>(_onLoadPartners);
    on<AddPartner>(_onAddPartner);
  }

  Future<void> _onLoadPartners(
    LoadPartners event,
    Emitter<PartnerState> emit,
  ) async {
    emit(PartnerLoading());

    try {
      // Passando o filtro (type e query) para o repositório
      final partners = await repository.getPartners(
        type: event.type,
        query: event.query,
      );
      emit(PartnerLoaded(partners));
    } catch (e) {
      emit(PartnerError('Erro ao buscar parceiros: $e'));
    }
  }

  Future<void> _onAddPartner(
    AddPartner event,
    Emitter<PartnerState> emit,
  ) async {
    emit(PartnerLoading());

    try {
      await repository.createPartner(event.partner);
      // Recarrega sem filtro após salvar para mostrar o novo na lista
      add(const LoadPartners());
    } catch (e) {
      emit(PartnerError('Erro ao salvar parceiro: $e'));
    }
  }
}
