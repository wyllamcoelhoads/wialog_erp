class UserEntity {
  final int id;
  final int employeeId;
  final String? employeeName;
  final String email;
  final String password;
  final int roleId;
  final String? roleName; // Trazido do banco
  final bool isActive;
  final String theme;
  final Map<String, bool>? customPermissions;
  final Map<String, bool> rolePermissions; // Permissões herdadas de cargo

  UserEntity({
    required this.id,
    required this.employeeId,
    this.employeeName,
    required this.email,
    required this.password,
    required this.roleId,
    this.roleName,
    this.isActive = true,
    this.theme = 'light',
    this.customPermissions = const {},
    this.rolePermissions = const {},
  });
}
