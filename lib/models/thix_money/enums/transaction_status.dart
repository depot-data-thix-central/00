enum TransactionStatus {
  pending,
  success,
  failed,
  cancelled;

  String get displayName {
    switch (this) {
      case TransactionStatus.pending:
        return 'En attente';
      case TransactionStatus.success:
        return 'Réussi';
      case TransactionStatus.failed:
        return 'Échoué';
      case TransactionStatus.cancelled:
        return 'Annulé';
    }
  }

  String get apiValue {
    switch (this) {
      case TransactionStatus.pending:
        return 'pending';
      case TransactionStatus.success:
        return 'success';
      case TransactionStatus.failed:
        return 'failed';
      case TransactionStatus.cancelled:
        return 'cancelled';
    }
  }

  static TransactionStatus fromApiValue(String value) {
    switch (value) {
      case 'pending':
        return TransactionStatus.pending;
      case 'success':
        return TransactionStatus.success;
      case 'failed':
        return TransactionStatus.failed;
      case 'cancelled':
        return TransactionStatus.cancelled;
      default:
        return TransactionStatus.pending;
    }
  }
}
