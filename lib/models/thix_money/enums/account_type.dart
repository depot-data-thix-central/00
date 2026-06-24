enum AccountType {
  principal,
  epargne,
  usd,
  prepayee;

  String get displayName {
    switch (this) {
      case AccountType.principal:
        return 'Compte principal';
      case AccountType.epargne:
        return 'Épargne';
      case AccountType.usd:
        return 'Dollars (USD)';
      case AccountType.prepayee:
        return 'Carte prépayée';
    }
  }

  String get apiValue {
    switch (this) {
      case AccountType.principal:
        return 'principal';
      case AccountType.epargne:
        return 'epargne';
      case AccountType.usd:
        return 'usd';
      case AccountType.prepayee:
        return 'prepayee';
    }
  }

  static AccountType fromApiValue(String value) {
    switch (value) {
      case 'principal':
        return AccountType.principal;
      case 'epargne':
        return AccountType.epargne;
      case 'usd':
        return AccountType.usd;
      case 'prepayee':
        return AccountType.prepayee;
      default:
        return AccountType.principal;
    }
  }
}
