class PaymentMethodEntity {
  final int id;
  final String name;
  final bool isActive;

  PaymentMethodEntity({
    required this.id,
    required this.name,
    this.isActive = true,
  });
}
