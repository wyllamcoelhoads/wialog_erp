class RoleEntity {
  final int id;
  final String name;
  final String? description;
  final Map<String, bool>? permissions;
  final bool isActive;

  RoleEntity({
    required this.id,
    required this.name,
    this.description,
    this.permissions = const {},
    this.isActive = true,
  });
}
