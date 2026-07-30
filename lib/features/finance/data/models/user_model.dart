import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.id,
    required super.employeeId,
    super.employeeName,
    required super.email,
    required super.password,
    required super.role,
    super.isActive,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      employeeId: map['employee_id'],
      employeeName: map['employee_name'], // Vem do JOIN
      email: map['email'],
      password: map['password'],
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.operational,
      ),
      isActive: map['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employee_id': employeeId,
      'email': email,
      'password': password,
      'role': role.name,
      'is_active': isActive,
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      employeeId: entity.employeeId,
      employeeName: entity.employeeName,
      email: entity.email,
      password: entity.password,
      role: entity.role,
      isActive: entity.isActive,
    );
  }
}
