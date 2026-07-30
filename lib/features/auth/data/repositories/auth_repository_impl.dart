import 'package:wialog_erp/features/auth/data/datasources/auth_data_source.dart';
import 'package:wialog_erp/features/auth/domain/repositories/auth_repository.dart';
import 'package:wialog_erp/features/finance/domain/entities/user_entity.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource dataSource;

  AuthRepositoryImpl(this.dataSource);

  @override
  Future<UserEntity?> authenticate(String email, String password) async {
    return await dataSource.authenticate(email, password);
  }
}
