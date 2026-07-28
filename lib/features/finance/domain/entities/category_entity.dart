class CategoryEntity {
  final int id;
  final String name;
  final bool isActive;

  CategoryEntity({required this.id, required this.name, this.isActive = true});
}
