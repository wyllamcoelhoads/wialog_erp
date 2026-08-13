import '../../domain/entities/settlement_entity.dart';

class SettlementModel extends SettlementEntity {
  SettlementModel({
    required super.id,
    required super.documentId,
    required super.amount,
    required super.paymentDate,
    required super.bankName,
    required super.methodName,
  });

  factory SettlementModel.fromMap(Map<String, dynamic> map) {
    return SettlementModel(
      id: map['id'],
      documentId: map['document_id'],
      amount: double.parse(map['amount'].toString()),
      paymentDate: map['payment_date'] is DateTime
          ? map['payment_date']
          : DateTime.parse(map['payment_date'].toString()),
      bankName: map['bank_name'] ?? 'Desconhecido',
      methodName: map['method_name'] ?? 'Desconhecido',
    );
  }
}
