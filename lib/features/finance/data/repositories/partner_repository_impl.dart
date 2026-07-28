import '../../domain/entities/partner_entity.dart';
import '../../domain/repositories/partner_repository.dart';
import '../datasources/partner_datasource.dart';
import '../models/partner_model.dart';

// O Domain dita as regras. O Data obedece e passa o trabalho sujo pro DataSource.
class PartnerRepositoryImpl implements PartnerRepository {
  final PartnerDataSource dataSource;

  PartnerRepositoryImpl(this.dataSource);

  @override
  Future<List<PartnerEntity>> getPartners({
    PartnerType? type,
    String? query,
  }) async {
    // Chama o DataSource passando o tipo e agora também o termo de busca (query)
    return await dataSource.getPartners(type: type, query: query);
  }

  @override
  Future<PartnerEntity> createPartner(PartnerEntity partner) async {
    // Transforma a Entity pura que veio da tela num Model (que sabe virar Map pro SQL)
    final model = PartnerModel.fromEntity(partner);
    return await dataSource.createPartner(model);
  }

  @override
  Future<PartnerEntity> updatePartner(PartnerEntity partner) async {
    final model = PartnerModel.fromEntity(partner);
    return await dataSource.updatePartner(model);
  }
}
