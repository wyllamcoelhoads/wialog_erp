import 'package:get_it/get_it.dart';
import 'package:wialog_erp/features/finance/data/datasources/document_data_source.dart';
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

// Imports de Documentos Financeiros
import '../../features/finance/data/repositories/document_repository_impl.dart';
import '../../features/finance/domain/repositories/document_repository.dart';
import '../../features/finance/presentation/bloc/document/document_bloc.dart';

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
  // FEATURES: CATEGORIAS (A correção está aqui!)
  // ==========================================
  sl.registerLazySingleton<CategoryDataSource>(
    () => CategoryPostgresDataSource(sl()),
  );
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(sl()),
  );
  sl.registerFactory<CategoryBloc>(() => CategoryBloc(sl()));

  // ==========================================
  // FEATURES: DOCUMENTOS FINANCEIROS
  // ==========================================
  sl.registerLazySingleton<DocumentDataSource>(
    () => DocumentPostgresDataSource(sl()),
  );
  sl.registerLazySingleton<DocumentRepository>(
    () => DocumentRepositoryImpl(sl()),
  );
  sl.registerFactory<DocumentBloc>(() => DocumentBloc(sl()));
}
