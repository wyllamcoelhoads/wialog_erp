import 'package:get_it/get_it.dart';
import '../database/database_connection.dart';

// Imports de Parceiros
import '../../features/finance/data/datasources/partner_datasource.dart';
import '../../features/finance/data/repositories/partner_repository_impl.dart';
import '../../features/finance/domain/repositories/partner_repository.dart';
import '../../features/finance/presentation/bloc/partner/partner_bloc.dart';

// Imports de Categorias
import '../../features/finance/data/datasources/category_datasource.dart';
import '../../features/finance/data/repositories/category_repository_impl.dart';
import '../../features/finance/domain/repositories/category_repository.dart';
import '../../features/finance/presentation/bloc/category/category_bloc.dart';

// Imports de Documentos Financeiros (MUITO IMPORTANTE)
import '../../features/finance/data/datasources/document_datasource.dart';
import '../../features/finance/data/repositories/document_repository_impl.dart';
import '../../features/finance/domain/repositories/document_repository.dart';
import '../../features/finance/presentation/bloc/document/document_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // 1. CORE (Banco de Dados)
  sl.registerLazySingleton<DatabaseConnection>(() => DatabaseConnection());

  // ==========================================
  // 2. FEATURES: PARCEIROS
  // ==========================================
  sl.registerLazySingleton<PartnerDataSource>(
    () => PartnerPostgresDataSource(sl()),
  );
  sl.registerLazySingleton<PartnerRepository>(
    () => PartnerRepositoryImpl(sl()),
  );
  sl.registerFactory<PartnerBloc>(() => PartnerBloc(sl()));

  // ==========================================
  // 3. FEATURES: CATEGORIAS
  // ==========================================
  sl.registerLazySingleton<CategoryDataSource>(
    () => CategoryPostgresDataSource(sl()),
  );
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(sl()),
  );
  sl.registerFactory<CategoryBloc>(() => CategoryBloc(sl()));

  // ==========================================
  // 4. FEATURES: DOCUMENTOS FINANCEIROS (A SOLUÇÃO DO ERRO ESTÁ AQUI)
  // ==========================================
  sl.registerLazySingleton<DocumentDataSource>(
    () => DocumentPostgresDataSource(sl()),
  );
  sl.registerLazySingleton<DocumentRepository>(
    () => DocumentRepositoryImpl(sl()),
  );
  sl.registerFactory<DocumentBloc>(() => DocumentBloc(sl()));
}
