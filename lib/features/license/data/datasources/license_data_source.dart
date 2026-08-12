import '../../../../core/database/database_connection.dart';
import '../../domain/entities/license_entity.dart';

class LicenseDataSource {
  final DatabaseConnection dbConnection;

  LicenseDataSource({required this.dbConnection});

  Future<LicenseEntity?> getCurrentLicense() async {
    await _syncWithFirebase();

    final result = await dbConnection.query(
      'SELECT * FROM company_license LIMIT 1',
    );

    if (result.isEmpty) return null;

    final map = result.first.toColumnMap();
    return LicenseEntity(
      documentNumber: map['document_number'] as String,
      companyName: map['company_name'] as String,
      localExpirationDate: map['local_expiration_date'] as DateTime,
      isActive: map['is_active'] as bool,
      trustUnlockUsed: map['trust_unlock_used'] as bool,
      trustUnlockExpiresAt: map['trust_unlock_expires_at'] as DateTime?,
    );
  }

  Future<void> applyTrustUnlock() async {
    final expiresAt = DateTime.now().add(const Duration(days: 4));

    await dbConnection.query(
      '''UPDATE company_license
      SET trust_unlock_used = true,
          trust_unlock_expires_at = @expiresAt
    ''',
      {'expiresAt': expiresAt},
    );
  }

  Future<void> _syncWithFirebase() async {
    try {
      // TODO: Implement Firebase synchronization logic here
      // EXEMPLO DE LOGICA FUTURA
      // FINAL DOC = AWAIT FirebaseFirestore.instance.collection('licenses').doc('current').get();
      // IF (doc.exists) {
      //   final data = doc.data();
      //   await dbConnection.query(
      //     '''UPDATE company_license
      //     SET document_number = @documentNumber,
      //         company_name = @companyName,
      //         local_expiration_date = @localExpirationDate,
      //         is_active = @isActive,
      //         trust_unlock_used = @trustUnlockUsed,
      //         trust_unlock_expires_at = @trustUnlockExpiresAt
      //   ''',
      //     {
      //       'documentNumber': data['document_number'],
      //       'companyName': data['company_name'],
      //       'localExpirationDate': data['local_expiration_date'],
      //       'isActive': data['is_active'],
      //       'trustUnlockUsed': data['trust_unlock_used'],
      //       'trustUnlockExpiresAt': data['trust_unlock_expires_at'],
      //     },
      //   );
      // }
    } catch (e) {
      // Handle any errors that occur during synchronization
      print(
        'Aviso: firebase offiline ou indisponível. Usando a licença local. Erro: $e',
      );
    }
  }
}
