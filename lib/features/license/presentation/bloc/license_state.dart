import 'package:equatable/equatable.dart';
import '../../domain/entities/license_entity.dart';

abstract class LicenseState extends Equatable {
  const LicenseState();

  @override
  List<Object?> get props => [];
}

class LicenseInitial extends LicenseState {}

class LicenseChecking extends LicenseState {}

class LicenseValid extends LicenseState {
  final LicenseEntity license;

  const LicenseValid(this.license);

  @override
  List<Object?> get props => [license];
}

class LicenseBlocked extends LicenseState {
  final LicenseEntity license;

  const LicenseBlocked(this.license);

  @override
  List<Object?> get props => [license];
}

class LicenseError extends LicenseState {}
