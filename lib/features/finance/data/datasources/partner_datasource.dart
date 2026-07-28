import '../../../../core/database/database_connection.dart';
import '../models/partner_model.dart';
import '../../domain/entities/partner_entity.dart'; // Para acessar o enum PartnerType

abstract class PartnerDataSource {
  Future<List<PartnerModel>> getPartners({PartnerType? type});
  Future<PartnerModel> createPartner(PartnerModel partner);
  Future<PartnerModel> updatePartner(PartnerModel partner);
}

class PartnerPostgresDataSource implements PartnerDataSource {
  final DatabaseConnection dbConnection;

  PartnerPostgresDataSource(this.dbConnection);

  @override
  Future<List<PartnerModel>> getPartners({PartnerType? type}) async {
    String sql = 'SELECT * FROM partners ORDER BY created_at DESC';
    Map<String, dynamic>? params;

    if (type != null) {
      sql = 'SELECT * FROM partners WHERE type = @type ORDER BY name ASC';
      params = {'type': type == PartnerType.supplier ? 'supplier' : 'client'};
    }

    final result = await dbConnection.query(sql, params);

    // O pacote postgres novo permite converter a linha do banco direto para Map
    return result
        .map((row) => PartnerModel.fromMap(row.toColumnMap()))
        .toList();
  }

  @override
  Future<PartnerModel> createPartner(PartnerModel partner) async {
    const sql = '''
      INSERT INTO partners (id, name, document, type, contact, category_or_city, is_active)
      VALUES (@id, @name, @document, @type, @contact, @category_or_city, @is_active)
      RETURNING *;
    ''';

    final result = await dbConnection.query(sql, partner.toMap());

    // Pega a linha recém-inserida que o banco retornou e devolve pro sistema
    return PartnerModel.fromMap(result.first.toColumnMap());
  }

  @override
  Future<PartnerModel> updatePartner(PartnerModel partner) async {
    const sql = '''
      UPDATE partners 
      SET name = @name, 
          document = @document, 
          type = @type, 
          contact = @contact, 
          category_or_city = @category_or_city, 
          is_active = @is_active
      WHERE id = @id
      RETURNING *;
    ''';

    final result = await dbConnection.query(sql, partner.toMap());

    return PartnerModel.fromMap(result.first.toColumnMap());
  }
}
