import '../entities/partner_entity.dart';

// O Domain dita as regras.
// Qualquer classe que quiser ser um Repositório de Parceiros precisa seguir este contrato.
abstract class PartnerRepository {
  // Agora o contrato exige que o repositório suporte a busca por tipo E por query (termo de pesquisa).
  Future<List<PartnerEntity>> getPartners({PartnerType? type, String? query});

  Future<PartnerEntity> createPartner(PartnerEntity partner);

  Future<PartnerEntity> updatePartner(PartnerEntity partner);

  Future<void> deletePartner(String id);
}
