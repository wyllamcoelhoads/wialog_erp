import '../../domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  CategoryModel({
    required super.id,
    required super.name,
    required super.type,
    required super.isActive,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    // Converte a string do banco para o Enum do Dart
    CategoryType mapType = CategoryType.supplier;
    if (map['type'] == 'receivable') mapType = CategoryType.receivable;
    if (map['type'] == 'payable') mapType = CategoryType.payable;

    return CategoryModel(
      id: map['id'] as int,
      name: map['name'] as String,
      type: mapType,
      isActive: map['is_active'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type':
          type.name, // Salva como string ('supplier', 'receivable', 'payable')
      'is_active': isActive,
    };
  }

  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      type: entity.type,
      isActive: entity.isActive,
    );
  }
}
