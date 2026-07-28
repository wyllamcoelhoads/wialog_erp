import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../finance/domain/repositories/partner_repository.dart';
import 'partner_event.dart';
import 'partner_state.dart';

// O BLoC escuta Eventos, processa as regras usando o Repository e emite Estados.
class PartnerBloc extends Bloc<PartnerEvent, PartnerState> {
  final PartnerRepository repository;

  // Ao criar o BLoC, ele começa no estado Inicial e define quais funções rodam para cada evento
  PartnerBloc(this.repository) : super(PartnerInitial()) {
    on<LoadPartners>(_onLoadPartners);
    on<AddPartner>(_onAddPartner);
  }

  Future<void> _onLoadPartners(
    LoadPartners event,
    Emitter<PartnerState> emit,
  ) async {
    emit(PartnerLoading()); // Avisa a tela para girar a bolinha de loading

    try {
      // Pede os dados ao Repositório (que vai no Postgres buscar)
      final partners = await repository.getPartners(type: event.type);
      emit(PartnerLoaded(partners)); // Entrega os dados pra tela!
    } catch (e) {
      emit(PartnerError('Erro ao carregar parceiros: $e'));
    }
  }

  Future<void> _onAddPartner(
    AddPartner event,
    Emitter<PartnerState> emit,
  ) async {
    emit(PartnerLoading());

    try {
      await repository.createPartner(event.partner);
      // Após inserir com sucesso, disparamos o evento de "Recarregar" a lista
      // Isso garante que a tabela estará sempre atualizada com os dados reais do banco!
      add(const LoadPartners());
    } catch (e) {
      emit(PartnerError('Erro ao salvar parceiro: $e'));
    }
  }
}
