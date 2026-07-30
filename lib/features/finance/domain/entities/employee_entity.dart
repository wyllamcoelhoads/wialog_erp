class EmployeeEntity {
  final int id;
  final String name;
  final String cpf;
  final int roleId;
  final String? roleName; // Trazido do banco por JOIN
  final String? licenseCategory;
  final DateTime? licenseExpiration;
  final bool isActive;

  EmployeeEntity({
    required this.id,
    required this.name,
    required this.cpf,
    required this.roleId,
    this.roleName,
    this.licenseCategory,
    this.licenseExpiration,
    this.isActive = true,
  });
}
