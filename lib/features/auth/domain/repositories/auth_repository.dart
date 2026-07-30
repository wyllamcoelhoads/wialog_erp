import 'package:wialog_erp/features/finance/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> authenticate(String email, String password);
}
