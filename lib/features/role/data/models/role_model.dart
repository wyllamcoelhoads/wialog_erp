import '../../domain/entities/role_entity.dart';

class RoleModel extends RoleEntity {
  RoleModel({
    required super.id,
    required super.name,
    super.description,
    super.isActive,
  });

  factory RoleModel.fromMap(Map<String, dynamic> map) {
    return RoleModel(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      isActive: map['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'is_active': isActive,
    };
  }

  factory RoleModel.fromEntity(RoleEntity entity) {
    return RoleModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      isActive: entity.isActive,
    );
  }
}
