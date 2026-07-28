import '../../../../core/database/database_connection.dart';
import '../models/partner_model.dart';
import '../../domain/entities/partner_entity.dart';

abstract class PartnerDataSource {
  Future<List<PartnerModel>> getPartners({PartnerType? type, String? query});
  Future<PartnerModel> createPartner(PartnerModel partner);
  Future<PartnerModel> updatePartner(PartnerModel partner);
}

class PartnerPostgresDataSource implements PartnerDataSource {
  final DatabaseConnection dbConnection;

  PartnerPostgresDataSource(this.dbConnection);

  @override
  Future<List<PartnerModel>> getPartners({
    PartnerType? type,
    String? query,
  }) async {
    List<String> whereClauses = [];
    Map<String, dynamic> params = {};

    // Filtro por Tipo (Cliente ou Fornecedor)
    if (type != null) {
      whereClauses.add('type = @type');
      params['type'] = type == PartnerType.supplier ? 'supplier' : 'client';
    }

    // Filtro por Query (Busca por nome/razão social)
    if (query != null && query.isNotEmpty) {
      whereClauses.add(
        'name ILIKE @query or id ILIKE @query or document ILIKE @query',
      );
      params['query'] = '%$query%'; // ILIKE busca em qualquer parte da string
    }

    String sql = 'SELECT * FROM partners';
    if (whereClauses.isNotEmpty) {
      sql += ' WHERE ${whereClauses.join(' AND ')}';
    }
    sql += ' ORDER BY created_at DESC';

    final result = await dbConnection.query(sql, params);

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
