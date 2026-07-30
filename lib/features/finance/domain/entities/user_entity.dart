enum UserRole { admin, financial, operational }

class UserEntity {
  final int id;
  final int employeeId;
  final String? employeeName; // Trazido pelo JOIN para mostrar na tela
  final String email;
  final String password;
  final UserRole role;
  final bool isActive;

  UserEntity({
    required this.id,
    required this.employeeId,
    this.employeeName,
    required this.email,
    required this.password,
    required this.role,
    this.isActive = true,
  });
}
