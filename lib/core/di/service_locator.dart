import 'package:get_it/get_it.dart';
import 'package:wialog_erp/features/auth/data/datasources/auth_data_source.dart';
import 'package:wialog_erp/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:wialog_erp/features/auth/domain/repositories/auth_repository.dart';
import 'package:wialog_erp/features/auth/presentation/bloc/auth_event.dart';
import 'package:wialog_erp/features/finance/data/datasources/bank_account_datasource.dart';
import 'package:wialog_erp/features/finance/data/datasources/category_datasource.dart';
import 'package:wialog_erp/features/finance/data/datasources/document_data_source.dart';
import 'package:wialog_erp/features/finance/data/datasources/employee_data_source.dart';
import 'package:wialog_erp/features/finance/data/datasources/partner_datasource.dart';
import 'package:wialog_erp/features/finance/data/datasources/payment_method_data_source.dart';
import 'package:wialog_erp/features/finance/data/datasources/user_data_source.dart';
import 'package:wialog_erp/features/finance/data/repositories/bank_account_repository_impl.dart';
import 'package:wialog_erp/features/finance/data/repositories/category_repository_impl.dart';
import 'package:wialog_erp/features/finance/data/repositories/document_repository_impl.dart';
import 'package:wialog_erp/features/finance/data/repositories/employee_repository_impl.dart';
import 'package:wialog_erp/features/finance/data/repositories/partner_repository_impl.dart';
import 'package:wialog_erp/features/finance/data/repositories/payment_method_repository_impl.dart';
import 'package:wialog_erp/features/finance/data/repositories/user_repository_impl.dart';
import 'package:wialog_erp/features/finance/domain/repositories/bank_account_repository.dart';
import 'package:wialog_erp/features/finance/domain/repositories/category_repository.dart';
import 'package:wialog_erp/features/finance/domain/repositories/document_repository.dart';
import 'package:wialog_erp/features/finance/domain/repositories/employee_repository.dart';
import 'package:wialog_erp/features/finance/domain/repositories/partner_repository.dart';
import 'package:wialog_erp/features/finance/domain/repositories/payment_method_repository.dart';
import 'package:wialog_erp/features/finance/domain/repositories/user_repository.dart';
import 'package:wialog_erp/features/finance/presentation/bloc/bank_account/bank_account_bloc.dart';
import 'package:wialog_erp/features/finance/presentation/bloc/category/category_bloc.dart';
import 'package:wialog_erp/features/finance/presentation/bloc/document/document_bloc.dart';
import 'package:wialog_erp/features/finance/presentation/bloc/employee/employee_bloc.dart';
import 'package:wialog_erp/features/finance/presentation/bloc/partner/partner_bloc.dart';
import 'package:wialog_erp/features/finance/presentation/bloc/payment_method/payment_method_bloc.dart';
import 'package:wialog_erp/features/finance/presentation/bloc/user/user_bloc.dart';
import 'package:wialog_erp/features/role/data/datasources/role_data_source.dart';
import 'package:wialog_erp/features/role/data/repositories/role_repository_impl.dart';
import 'package:wialog_erp/features/role/domain/repositories/role_repository.dart';
import 'package:wialog_erp/features/role/presentation/bloc/role_bloc.dart';
import '../database/database_connection.dart';

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

  // ==========================================
  // 5. FEATURES: CONTAS BANCÁRIAS
  // ==========================================
  // Dentro da função initDependencies:
  sl.registerLazySingleton<BankAccountDataSource>(
    () => BankAccountPostgresDataSource(sl()),
  );
  sl.registerLazySingleton<BankAccountRepository>(
    () => BankAccountRepositoryImpl(sl()),
  );
  sl.registerFactory<BankAccountBloc>(() => BankAccountBloc(sl()));

  // NOVO: FEATURES: FORMAS DE PAGAMENTO
  sl.registerLazySingleton<PaymentMethodDataSource>(
    () => PaymentMethodPostgresDataSource(sl()),
  );
  sl.registerLazySingleton<PaymentMethodRepository>(
    () => PaymentMethodRepositoryImpl(sl()),
  );
  sl.registerFactory<PaymentMethodBloc>(() => PaymentMethodBloc(sl()));
  // NOVO: FEATURES: FUNCIONÁRIOS
  sl.registerLazySingleton<EmployeeDataSource>(
    () => EmployeePostgresDataSource(sl()),
  );
  sl.registerLazySingleton<EmployeeRepository>(
    () => EmployeeRepositoryImpl(sl()),
  );
  sl.registerFactory<EmployeeBloc>(() => EmployeeBloc(sl()));
  // ==========================
  // CARGOS E PERMISSÕES
  // ==========================
  sl.registerLazySingleton<RoleDataSource>(() => RolePostgresDataSource(sl()));
  sl.registerLazySingleton<RoleRepository>(() => RoleRepositoryImpl(sl()));
  sl.registerFactory<RoleBloc>(() => RoleBloc(sl()));
  // ==========================
  // NOVO: AUTENTICAÇÃO (LOGIN)
  // ==========================
  sl.registerLazySingleton<AuthDataSource>(() => AuthPostgresDataSource(sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  // O AuthBloc agora recebe o repositório
  sl.registerFactory<AuthBloc>(() => AuthBloc(sl()));
  // FEATURES: USUÁRIOS E AUTENTICAÇÃO
  sl.registerLazySingleton<UserDataSource>(() => UserPostgresDataSource(sl()));
  sl.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(sl()));
  sl.registerFactory<UserBloc>(() => UserBloc(sl()));
}
