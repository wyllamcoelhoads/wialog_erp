import '../../domain/entities/role_entity.dart';
import 'dart:convert';

class RoleModel extends RoleEntity {
  RoleModel({
    required super.id,
    required super.name,
    super.description,
    super.permissions,
    super.isActive,
  });

  factory RoleModel.fromMap(Map<String, dynamic> map) {
    Map<String, bool> parsedPermissions = {};
    if (map['permissions'] != null &&
        map['permissions'].toString().isNotEmpty) {
      // Esta linha garante que o mapa de permissões seja convertido corretamente para Map<String, bool>
      try {
        final decodedPermissions = jsonDecode(map['permissions']);
        parsedPermissions = Map<String, bool>.from(decodedPermissions);
      } catch (e) {
        // Se ocorrer um erro ao decodificar, podemos definir permissions como um mapa vazio
      }
    }
    return RoleModel(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      permissions: parsedPermissions,
      isActive: map['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'permissions': jsonEncode(permissions),
      'is_active': isActive,
    };
  }

  factory RoleModel.fromEntity(RoleEntity entity) {
    return RoleModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      permissions: entity.permissions,
      isActive: entity.isActive,
    );
  }
}
