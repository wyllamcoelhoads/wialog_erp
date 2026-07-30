import '../../domain/entities/employee_entity.dart';

class EmployeeModel extends EmployeeEntity {
  EmployeeModel({
    required super.id,
    required super.name,
    required super.cpf,
    required super.role,
    super.licenseCategory,
    super.licenseExpiration,
    super.isActive,
  });

  factory EmployeeModel.fromMap(Map<String, dynamic> map) {
    return EmployeeModel(
      id: map['id'],
      name: map['name'],
      cpf: map['cpf'],
      role: EmployeeRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => EmployeeRole.operational,
      ),
      licenseCategory: map['license_category'],
      licenseExpiration: map['license_expiration'] != null
          ? (map['license_expiration'] is DateTime
                ? map['license_expiration']
                : DateTime.parse(map['license_expiration'].toString()))
          : null,
      isActive: map['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'cpf': cpf,
      'role': role.name,
      'license_category': licenseCategory,
      'license_expiration': licenseExpiration?.toIso8601String().split('T')[0],
      'is_active': isActive,
    };
  }

  factory EmployeeModel.fromEntity(EmployeeEntity entity) {
    return EmployeeModel(
      id: entity.id,
      name: entity.name,
      cpf: entity.cpf,
      role: entity.role,
      licenseCategory: entity.licenseCategory,
      licenseExpiration: entity.licenseExpiration,
      isActive: entity.isActive,
    );
  }
}
