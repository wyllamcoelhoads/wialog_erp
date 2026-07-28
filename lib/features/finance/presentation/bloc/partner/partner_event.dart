import 'package:equatable/equatable.dart';
import '../../../../finance/domain/entities/partner_entity.dart';

abstract class PartnerEvent extends Equatable {
  const PartnerEvent();

  @override
  List<Object?> get props => [];
}

// Evento: Pedir para a tela carregar a lista do banco
class LoadPartners extends PartnerEvent {
  final PartnerType? type; // Pode carregar só clientes, só fornecedores ou tudo

  const LoadPartners({this.type});

  @override
  List<Object?> get props => [type];
}

// Evento: Pedir para salvar um novo parceiro no banco
class AddPartner extends PartnerEvent {
  final PartnerEntity partner;

  const AddPartner(this.partner);

  @override
  List<Object?> get props => [partner];
}
