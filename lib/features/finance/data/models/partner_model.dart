import '../../domain/entities/partner_entity.dart';

class PartnerModel extends PartnerEntity {
  PartnerModel({
    required super.id,
    required super.name,
    required super.document,
    required super.type,
    required super.contact,
    super.categoryId,
    super.city,
    super.isActive,
  });

  factory PartnerModel.fromMap(Map<String, dynamic> map) {
    return PartnerModel(
      id: map['id'] as String,
      name: map['name'] as String,
      document: map['document'] as String,
      type: map['type'] == 'supplier'
          ? PartnerType.supplier
          : PartnerType.client,
      contact: map['contact'] as String,
      categoryId: map['category_id'] != null ? map['category_id'] as int : null,
      city: map['category_or_city'] as String?,
      isActive: map['is_active'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'document': document,
      'type': type == PartnerType.supplier ? 'supplier' : 'client',
      'contact': contact,
      'category_id': categoryId,
      'category_or_city': city,
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
      categoryId: entity.categoryId,
      city: entity.city,
      isActive: entity.isActive,
    );
  }
}
