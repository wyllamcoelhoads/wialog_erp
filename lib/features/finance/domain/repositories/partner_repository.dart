// Camada Pura: Domain
// Aqui nós apenas ditamos AS REGRAS do que o sistema precisa fazer.
// Como ele vai fazer (SQL, Firebase, Memória) não importa para o Domain.

import '../entities/partner_entity.dart';

abstract class PartnerRepository {
  // Regra 1: O sistema deve conseguir buscar todos os parceiros (opcionalmente filtrando por tipo)
  Future<List<PartnerEntity>> getPartners({PartnerType? type});

  // Regra 2: O sistema deve conseguir salvar um novo parceiro
  Future<PartnerEntity> createPartner(PartnerEntity partner);

  // Regra 3: O sistema deve conseguir atualizar um parceiro existente
  Future<PartnerEntity> updatePartner(PartnerEntity partner);
}
