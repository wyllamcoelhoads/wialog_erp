enum CategoryType { supplier, receivable, payable }

class CategoryEntity {
  final int id;
  final String name;
  final CategoryType type; // NOVO CAMPO
  final bool isActive;

  CategoryEntity({
    required this.id,
    required this.name,
    required this.type, // NOVO CAMPO
    this.isActive = true,
  });
}
