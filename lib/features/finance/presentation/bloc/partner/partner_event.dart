import 'package:equatable/equatable.dart';
import '../../../../finance/domain/entities/partner_entity.dart';

abstract class PartnerEvent extends Equatable {
  const PartnerEvent();

  @override
  List<Object?> get props => [];
}

// Evento: Pedir para a tela carregar a lista do banco com filtros opcionais
class LoadPartners extends PartnerEvent {
  final PartnerType? type;
  final String? query; // NOVO: Campo de busca

  const LoadPartners({this.type, this.query});

  @override
  List<Object?> get props => [type, query];
}

// Evento: Pedir para salvar um novo parceiro
class AddPartner extends PartnerEvent {
  final PartnerEntity partner;

  const AddPartner(this.partner);

  @override
  List<Object?> get props => [partner];
}

// Evento: Atualizar parceiro existente
class UpdatePartner extends PartnerEvent {
  final PartnerEntity partner;

  const UpdatePartner(this.partner);

  @override
  List<Object?> get props => [partner];
}

// Evento: Deletar parceiro (Soft Delete)
class DeletePartner extends PartnerEvent {
  final String id;

  const DeletePartner(this.id);

  @override
  List<Object?> get props => [id];
}
