import 'package:flutter/services.dart';
import 'dart:convert';

class NfcPaymentData {
  final String cardId;
  final double amount;
  final String merchantId;

  NfcPaymentData({
    required this.cardId,
    required this.amount,
    required this.merchantId,
  });

  factory NfcPaymentData.fromJson(Map<String, dynamic> json) {
    return NfcPaymentData(
      cardId: json['cardId'],
      amount: (json['amount'] as num).toDouble(),
      merchantId: json['merchantId'],
    );
  }
}

class NfcHandler {
  static const MethodChannel _channel = MethodChannel('com.thix.nfc');

  /// Vérifie si le NFC est disponible sur l'appareil
  Future<bool> isAvailable() async {
    try {
      final bool available = await _channel.invokeMethod('isNfcAvailable');
      return available;
    } on PlatformException catch (e) {
      print('NFC availability error: ${e.message}');
      return false;
    }
  }

  /// Démarre la lecture d'une carte NFC (attente d'approche)
  Future<NfcPaymentData?> readPaymentData() async {
    try {
      final Map<String, dynamic>? result = await _channel.invokeMethod('readNfcPayment');
      if (result != null) {
        return NfcPaymentData.fromJson(result);
      }
      return null;
    } on PlatformException catch (e) {
      print('NFC read error: ${e.message}');
      return null;
    }
  }

  /// Écrit des données sur une carte NFC (ex. pour configurer une carte)
  Future<bool> writeCardData(String cardId, String encryptedPin) async {
    try {
      final bool success = await _channel.invokeMethod('writeNfcCard', {
        'cardId': cardId,
        'encryptedPin': encryptedPin,
      });
      return success;
    } on PlatformException catch (e) {
      print('NFC write error: ${e.message}');
      return false;
    }
  }

  /// Arrête la lecture NFC en cours
  Future<void> stopReading() async {
    try {
      await _channel.invokeMethod('stopNfcReading');
    } on PlatformException catch (e) {
      print('NFC stop error: ${e.message}');
    }
  }
}
