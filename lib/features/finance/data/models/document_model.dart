import '../../domain/entities/financial_document_entity.dart';

class DocumentModel extends FinancialDocumentEntity {
  DocumentModel({
    required super.id,
    required super.description,
    required super.type,
    required super.value,
    required super.balance,
    required super.issueDate,
    required super.dueDate,
    super.paymentDate,
    required super.categoryId,
    required super.partnerId,
    required super.status,
    super.notes,
    super.isActive,
    super.partnerName,
    super.categoryName,
  });

  factory DocumentModel.fromMap(Map<String, dynamic> map) {
    return DocumentModel(
      id: map['id'],
      description: map['description'],
      type: map['type'] == 'receivable'
          ? DocumentType.receivable
          : DocumentType.payable,
      value: double.parse(map['value'].toString()),
      balance: double.parse(map['balance'].toString()),
      issueDate: map['issue_date'] is DateTime
          ? map['issue_date']
          : DateTime.parse(map['issue_date'].toString()),
      dueDate: map['due_date'] is DateTime
          ? map['due_date']
          : DateTime.parse(map['due_date'].toString()),
      paymentDate: map['payment_date'] != null
          ? (map['payment_date'] is DateTime
                ? map['payment_date']
                : DateTime.parse(map['payment_date'].toString()))
          : null,
      categoryId: map['category_id'],
      partnerId: map['partner_id'],
      status: map['status'] == 'paid'
          ? DocumentStatus.paid
          : (map['status'] == 'canceled'
                ? DocumentStatus.canceled
                : DocumentStatus.pending),
      notes: map['notes'],
      isActive: map['is_active'] ?? true,
      partnerName: map['partner_name'], // Trazido pelo JOIN no SQL
      categoryName: map['category_name'], // Trazido pelo JOIN no SQL
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'type': type == DocumentType.receivable ? 'receivable' : 'payable',
      'value': value,
      'balance': balance,
      'issue_date': issueDate.toIso8601String().split(
        'T',
      )[0], // Apenas a data (YYYY-MM-DD)
      'due_date': dueDate.toIso8601String().split('T')[0],
      'payment_date': paymentDate?.toIso8601String().split('T')[0],
      'category_id': categoryId,
      'partner_id': partnerId,
      'status': status.name,
      'notes': notes,
      'is_active': isActive,
    };
  }

  factory DocumentModel.fromEntity(FinancialDocumentEntity entity) {
    return DocumentModel(
      id: entity.id,
      description: entity.description,
      type: entity.type,
      value: entity.value,
      balance: entity.balance,
      issueDate: entity.issueDate,
      dueDate: entity.dueDate,
      paymentDate: entity.paymentDate,
      categoryId: entity.categoryId,
      partnerId: entity.partnerId,
      status: entity.status,
      notes: entity.notes,
      isActive: entity.isActive,
    );
  }
}
