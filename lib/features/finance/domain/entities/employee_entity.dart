enum EmployeeRole { driver, operational, financial, admin }

class EmployeeEntity {
  final int id;
  final String name;
  final String cpf;
  final EmployeeRole role;
  final String? licenseCategory;
  final DateTime? licenseExpiration;
  final bool isActive;

  EmployeeEntity({
    required this.id,
    required this.name,
    required this.cpf,
    required this.role,
    this.licenseCategory,
    this.licenseExpiration,
    this.isActive = true,
  });
}
