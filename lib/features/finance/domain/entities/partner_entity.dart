// Camada Pura: Domain
// Não importamos NADA do Flutter ou do Postgres aqui.

enum PartnerType { client, supplier }

class PartnerEntity {
  final String id; // ID que virá do banco de dados (ex: UUID)
  final String name; // Nome Completo ou Razão Social
  final String document; // CPF ou CNPJ
  final PartnerType type; // Cliente ou Fornecedor
  final String contact; // Telefone ou E-mail
  final String categoryOrCity; // Cidade (Cliente) ou Categoria (Fornecedor)
  final bool isActive; // Status: Ativo/Inativo

  PartnerEntity({
    required this.id,
    required this.name,
    required this.document,
    required this.type,
    required this.contact,
    required this.categoryOrCity,
    this.isActive = true, // Por padrão, nasce ativo
  });
}
