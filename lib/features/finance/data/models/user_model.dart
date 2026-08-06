import 'dart:convert';
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
    super.rolePermissions,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    // Helper para converter o texto JSON do banco em Mapa
    Map<String, bool> parsePerms(dynamic data) {
      if (data == null || data.toString().trim().isEmpty) return {};
      try {
        final decoded = jsonDecode(data.toString());
        return Map<String, bool>.from(decoded);
      } catch (e) {
        return {};
      }
    }

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
      customPermissions: parsePerms(map['custom_permissions']), // NOVO
      rolePermissions: parsePerms(map['role_permissions']), // NOVO
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
      'custom_permissions': jsonEncode(customPermissions), // NOVO
      'role_permissions': jsonEncode(rolePermissions), // NOVO
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
      rolePermissions: entity.rolePermissions, // NOVO
    );
  }
}
