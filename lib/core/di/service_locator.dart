import 'package:get_it/get_it.dart';
import 'package:wialog_erp/features/finance/data/repositories/partner_repository_impl.dart';
import '../database/database_connection.dart';

import '../../features/finance/data/datasources/partner_datasource.dart';
import '../../features/finance/domain/repositories/partner_repository.dart';
import '../../features/finance/presentation/bloc/partner/partner_bloc.dart';

// Instância global do Service Locator (apelidada de "sl")
final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ==========================================
  // CORE (Módulos Base do Sistema)
  // ==========================================

  // Registra a conexão de banco como "LazySingleton".
  // "Lazy" significa que ele só vai tentar conectar quando for usado pela primeira vez.
  // "Singleton" significa que a mesma conexão será usada no app inteiro.
  sl.registerLazySingleton<DatabaseConnection>(() => DatabaseConnection());

  // ==========================================
  // FEATURES (Nossas telas e regras de negócio)
  // ==========================================

  // 1. DataSources (Acesso direto ao banco/SQL)
  // O "sl()" faz o GetIt injetar o DatabaseConnection que criamos lá em cima automaticamente!
  sl.registerLazySingleton<PartnerDataSource>(
    () => PartnerPostgresDataSource(sl()),
  );

  // 2. Repositories (Cumpre o contrato do Domain usando o DataSource)
  sl.registerLazySingleton<PartnerRepository>(
    () => PartnerRepositoryImpl(sl()),
  );

  // 3. BLoCs (Gerenciamento de Estado da Tela)
  // Usamos Factory para o BLoC. Assim, ele recria o BLoC sempre que abrirmos a tela limpa.
  sl.registerFactory<PartnerBloc>(() => PartnerBloc(sl()));
}
