enum DocumentType { payable, receivable }

enum DocumentStatus { pending, paid, canceled }

class FinancialDocumentEntity {
  final String id;
  final String description;
  final DocumentType type;
  final double value;
  final double balance; // Saldo da duplicata
  final DateTime issueDate; // Data de cadastro
  final DateTime dueDate; // Vencimento
  final DateTime? paymentDate;
  final int categoryId;
  final String partnerId;
  final DocumentStatus status;
  final String? notes;
  final bool isActive;

  // Propriedades extras (úteis para exibir na tabela sem precisar fazer requisições adicionais)
  final String? partnerName;
  final String? categoryName;

  FinancialDocumentEntity({
    required this.id,
    required this.description,
    required this.type,
    required this.value,
    required this.balance,
    required this.issueDate,
    required this.dueDate,
    this.paymentDate,
    required this.categoryId,
    required this.partnerId,
    required this.status,
    this.notes,
    this.isActive = true,
    this.partnerName,
    this.categoryName,
  });
}
