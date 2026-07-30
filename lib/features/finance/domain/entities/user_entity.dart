class UserEntity {
  final int id;
  final int employeeId;
  final String? employeeName;
  final String email;
  final String password;
  final int roleId;
  final String? roleName; // Trazido do banco
  final bool isActive;

  UserEntity({
    required this.id,
    required this.employeeId,
    this.employeeName,
    required this.email,
    required this.password,
    required this.roleId,
    this.roleName,
    this.isActive = true,
  });
}
