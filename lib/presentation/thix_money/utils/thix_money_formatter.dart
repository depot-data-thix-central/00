import 'package:intl/intl.dart';

class ThixMoneyFormatter {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'fr_FR',
    symbol: 'FC',
    decimalDigits: 0,
  );

  static final NumberFormat _usdFormat = NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 2,
  );

  static final NumberFormat _eurFormat = NumberFormat.currency(
    locale: 'fr_FR',
    symbol: '€',
    decimalDigits: 2,
  );

  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

  /// Formate un montant en FC
  static String formatFC(double amount) {
    return _currencyFormat.format(amount);
  }

  /// Formate un montant en USD
  static String formatUSD(double amount) {
    return _usdFormat.format(amount);
  }

  /// Formate un montant en EUR
  static String formatEUR(double amount) {
    return _eurFormat.format(amount);
  }

  /// Formate un montant selon la devise
  static String formatAmount(double amount, String currency) {
    switch (currency.toUpperCase()) {
      case 'USD':
        return formatUSD(amount);
      case 'EUR':
        return formatEUR(amount);
      default:
        return formatFC(amount);
    }
  }

  /// Formate une date
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  /// Formate une heure
  static String formatTime(DateTime date) {
    return _timeFormat.format(date);
  }

  /// Formate une date et heure complètes
  static String formatDateTime(DateTime date) {
    return _dateTimeFormat.format(date);
  }

  /// Formate un numéro de transaction (affichage court)
  static String formatTransactionId(String id) {
    if (id.length <= 8) return id;
    return '${id.substring(0, 6)}...${id.substring(id.length - 4)}';
  }

  /// Convertit un montant FC en Euro (taux fixe exemple, à remplacer par API)
  static double fcToEuro(double fc, double rate) {
    return fc / rate;
  }

  /// Convertit un montant Euro en FC
  static double euroToFc(double euro, double rate) {
    return euro * rate;
  }
}
