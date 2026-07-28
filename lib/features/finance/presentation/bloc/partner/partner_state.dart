import 'package:equatable/equatable.dart';
import '../../../../finance/domain/entities/partner_entity.dart';

abstract class PartnerState extends Equatable {
  const PartnerState();

  @override
  List<Object?> get props => [];
}

// Estado 1: Tela acabou de abrir, nada aconteceu ainda
class PartnerInitial extends PartnerState {}

// Estado 2: Mostra a bolinha girando (CircularProgressIndicator)
class PartnerLoading extends PartnerState {}

// Estado 3: Sucesso! Devolve a lista do banco para desenhar a tabela
class PartnerLoaded extends PartnerState {
  final List<PartnerEntity> partners;

  const PartnerLoaded(this.partners);

  @override
  List<Object?> get props => [partners];
}

// Estado 4: Deu erro! Exibe o SnackBar vermelho
class PartnerError extends PartnerState {
  final String message;

  const PartnerError(this.message);

  @override
  List<Object?> get props => [message];
}
