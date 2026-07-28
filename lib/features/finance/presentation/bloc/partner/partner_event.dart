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
  final String? query; // Campo de busca

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

// NOVO: Evento para atualizar um parceiro existente (edição)
class UpdatePartner extends PartnerEvent {
  final PartnerEntity partner;

  const UpdatePartner(this.partner);

  @override
  List<Object?> get props => [partner];
}

// NOVO: Evento para excluir um parceiro pelo id.
// Recebe o filtro atual (type/query) para recarregar a lista certa
// depois de excluir, em vez de sempre voltar para "todos".
class DeletePartner extends PartnerEvent {
  final String id;
  final PartnerType? currentType;
  final String? currentQuery;

  const DeletePartner(this.id, {this.currentType, this.currentQuery});

  @override
  List<Object?> get props => [id, currentType, currentQuery];
}
