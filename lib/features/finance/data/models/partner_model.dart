import '../../domain/entities/partner_entity.dart';

// O Model é uma extensão da Entity. Ele tem as mesmas propriedades,
// mas adiciona a "inteligência" de saber como se converter de/para o Banco de Dados.
class PartnerModel extends PartnerEntity {
  PartnerModel({
    required super.id,
    required super.name,
    required super.document,
    required super.type,
    required super.contact,
    required super.categoryOrCity,
    super.isActive,
  });

  // Pega uma linha do PostgreSQL (que vem como um Map) e transforma num Objeto Dart
  factory PartnerModel.fromMap(Map<String, dynamic> map) {
    return PartnerModel(
      id: map['id'] as String,
      name: map['name'] as String,
      document: map['document'] as String,
      // Converte a String do banco de volta para o Enum do Dart
      type: map['type'] == 'supplier'
          ? PartnerType.supplier
          : PartnerType.client,
      contact: map['contact'] as String,
      categoryOrCity: map['category_or_city'] as String,
      isActive: map['is_active'] as bool,
    );
  }

  // Pega o Objeto Dart e transforma num Map para injetarmos no comando SQL
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'document': document,
      'type': type == PartnerType.supplier ? 'supplier' : 'client',
      'contact': contact,
      'category_or_city': categoryOrCity,
      'is_active': isActive,
    };
  }

  factory PartnerModel.fromEntity(PartnerEntity entity) {
    return PartnerModel(
      id: entity.id,
      name: entity.name,
      document: entity.document,
      type: entity.type,
      contact: entity.contact,
      categoryOrCity: entity.categoryOrCity,
      isActive: entity.isActive,
    );
  }
}
