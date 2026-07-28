import 'package:get_it/get_it.dart';
import '../database/database_connection.dart';

import '../../features/finance/data/datasources/partner_datasource.dart';
import '../../features/finance/data/repositories/partner_repository_impl.dart';
import '../../features/finance/domain/repositories/partner_repository.dart';
import '../../features/finance/presentation/bloc/partner/partner_bloc.dart';

// Novos imports para Categorias
import '../../features/finance/data/datasources/category_datasource.dart';
import '../../features/finance/data/repositories/category_repository_impl.dart';
import '../../features/finance/domain/repositories/category_repository.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // CORE
  sl.registerLazySingleton<DatabaseConnection>(() => DatabaseConnection());

  // ==========================================
  // FEATURES: PARCEIROS
  // ==========================================
  sl.registerLazySingleton<PartnerDataSource>(
    () => PartnerPostgresDataSource(sl()),
  );
  sl.registerLazySingleton<PartnerRepository>(
    () => PartnerRepositoryImpl(sl()),
  );
  sl.registerFactory<PartnerBloc>(() => PartnerBloc(sl()));

  // ==========================================
  // FEATURES: CATEGORIAS (Corrigido)
  // ==========================================
  // DataSource
  sl.registerLazySingleton<CategoryDataSource>(
    () => CategoryPostgresDataSource(sl()),
  );

  // Repository (Bind da Interface com a Implementação)
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(sl()),
  );
}
