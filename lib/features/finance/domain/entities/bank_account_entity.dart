enum AccountType { checking, savings, cash }

class BankAccountEntity {
  final int id;
  final String description;
  final int bankId;
  final String bankName; // Join
  final String? agency;
  final String? accountNumber;
  final AccountType accountType;
  final double initialBalance;
  final double currentBalance;
  final bool isActive;

  BankAccountEntity({
    required this.id,
    required this.description,
    required this.bankId,
    required this.bankName,
    this.agency,
    this.accountNumber,
    required this.accountType,
    this.initialBalance = 0.0,
    this.currentBalance = 0.0,
    this.isActive = true,
  });
}
