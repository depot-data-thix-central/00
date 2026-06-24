enum MerchantStatus {
  notRequested,
  pending,
  approved,
  rejected;

  String get displayName {
    switch (this) {
      case MerchantStatus.notRequested:
        return 'Non demandé';
      case MerchantStatus.pending:
        return 'En attente';
      case MerchantStatus.approved:
        return 'Approuvé';
      case MerchantStatus.rejected:
        return 'Rejeté';
    }
  }

  String get apiValue {
    switch (this) {
      case MerchantStatus.notRequested:
        return 'not_requested';
      case MerchantStatus.pending:
        return 'pending';
      case MerchantStatus.approved:
        return 'approved';
      case MerchantStatus.rejected:
        return 'rejected';
    }
  }

  static MerchantStatus fromApiValue(String value) {
    switch (value) {
      case 'not_requested':
        return MerchantStatus.notRequested;
      case 'pending':
        return MerchantStatus.pending;
      case 'approved':
        return MerchantStatus.approved;
      case 'rejected':
        return MerchantStatus.rejected;
      default:
        return MerchantStatus.notRequested;
    }
  }
}
