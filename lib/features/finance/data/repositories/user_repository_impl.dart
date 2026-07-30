import 'package:wialog_erp/features/finance/data/datasources/user_data_source.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final UserDataSource dataSource;
  UserRepositoryImpl(this.dataSource);

  @override
  Future<List<UserEntity>> getUsers({bool includeInactive = false}) async {
    return await dataSource.getUsers(includeInactive: includeInactive);
  }

  @override
  Future<UserEntity> createUser(UserEntity user) async {
    return await dataSource.createUser(UserModel.fromEntity(user));
  }

  @override
  Future<UserEntity> updateUser(UserEntity user) async {
    return await dataSource.updateUser(UserModel.fromEntity(user));
  }

  @override
  Future<void> deleteUser(int id) async {
    await dataSource.deleteUser(id);
  }
}
