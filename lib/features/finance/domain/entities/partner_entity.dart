// Camada Pura: Domain
enum PartnerType { client, supplier }

class PartnerEntity {
  final String id;
  final String name;
  final String document;
  final PartnerType type;
  final String contact;
  final int? categoryId; // NOVO: ID da categoria relacionada
  final String?
  city; // Mantemos cidade para clientes (ou usamos category_id se for fornecedor)
  final bool isActive;

  PartnerEntity({
    required this.id,
    required this.name,
    required this.document,
    required this.type,
    required this.contact,
    this.categoryId,
    this.city,
    this.isActive = true,
  });
}
