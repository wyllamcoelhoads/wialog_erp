import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.id,
    required super.employeeId,
    super.employeeName,
    required super.email,
    required super.password,
    required super.roleId,
    super.roleName,
    super.isActive,
    super.theme,
    super.customPermissions,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      employeeId: map['employee_id'],
      employeeName: map['employee_name'],
      email: map['email'],
      password: map['password'],
      roleId: map['role_id'],
      roleName: map['role_name'],
      isActive: map['is_active'] ?? true,
      theme: map['theme'] ?? 'light', // NOVO
      customPermissions: map['custom_permissions'], // NOVO
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employee_id': employeeId,
      'email': email,
      'password': password,
      'role_id': roleId,
      'is_active': isActive,
      'theme': theme, // NOVO
      'custom_permissions': customPermissions, // NOVO
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      employeeId: entity.employeeId,
      employeeName: entity.employeeName,
      email: entity.email,
      password: entity.password,
      roleId: entity.roleId,
      roleName: entity.roleName,
      isActive: entity.isActive,
      theme: entity.theme, // NOVO
      customPermissions: entity.customPermissions, // NOVO
    );
  }
}
