class LicenseEntity {
  final String documentNumber;
  final String companyName;
  final DateTime localExpirationDate;
  final bool isActive;
  final bool trustUnlockUsed;
  final DateTime? trustUnlockExpiresAt;

  LicenseEntity({
    required this.documentNumber,
    required this.companyName,
    required this.localExpirationDate,
    required this.isActive,
    required this.trustUnlockUsed,
    this.trustUnlockExpiresAt,
  });

  bool get isSystemUnlocked {
    final now = DateTime.now();

    if (!isActive) {
      return false;
    }

    if (localExpirationDate.isAfter(now)) {
      return true;
    }
    if (trustUnlockUsed && trustUnlockExpiresAt != null) {
      if (trustUnlockExpiresAt!.isAfter(now)) {
        return true;
      }
    }
    return false;
  }
}
