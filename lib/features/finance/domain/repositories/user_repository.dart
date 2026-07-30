import '../entities/user_entity.dart';

abstract class UserRepository {
  Future<List<UserEntity>> getUsers({bool includeInactive = false});
  Future<UserEntity> createUser(UserEntity user);
  Future<UserEntity> updateUser(UserEntity user);
  Future<void> deleteUser(int id);
}
