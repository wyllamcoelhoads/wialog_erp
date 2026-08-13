class SettlementEntity {
  final int id;
  final String documentId;
  final double amount;
  final DateTime paymentDate;
  final String bankName;
  final String methodName;

  SettlementEntity({
    required this.id,
    required this.documentId,
    required this.amount,
    required this.paymentDate,
    required this.bankName,
    required this.methodName,
  });
}
