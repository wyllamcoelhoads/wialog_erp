import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wialog_erp/features/license/data/datasources/license_data_source.dart';
import 'license_event.dart';
import 'license_state.dart';

class LicenseBloc extends Bloc<LicenseEvent, LicenseState> {
  final LicenseDataSource dataSource;

  LicenseBloc(this.dataSource) : super(LicenseInitial()) {
    on<CheckLicense>((event, emit) async {
      emit(LicenseChecking());
      try {
        final license = await dataSource.getCurrentLicense();

        if (license == null) {
          emit(LicenseError());
        } else if (license.isSystemUnlocked) {
          emit(LicenseValid(license));
        } else {
          emit(LicenseBlocked(license));
        }
      } catch (e) {
        emit(LicenseError());
      }
    });

    on<ApplyTrustUnlock>((event, emit) async {
      emit(LicenseChecking());
      try {
        await dataSource.applyTrustUnlock();
        // Checa de novo após aplicar para liberar a tela
        add(CheckLicense());
      } catch (e) {
        emit(LicenseError());
      }
    });
  }
}
