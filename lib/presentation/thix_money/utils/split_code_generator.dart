import 'dart:math';
import 'dart:convert';

class SplitCodeGenerator {
  static const String _chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ0123456789';
  static final Random _random = Random();

  /// Génère un code unique pour le paiement fractionné
  /// Format: THIX-XXXX-XXXX-XXXX
  static String generateCode() {
    final parts = <String>[];
    for (int i = 0; i < 3; i++) {
      final part = String.fromCharCodes(
        Iterable.generate(4, (_) => _chars.codeUnitAt(_random.nextInt(_chars.length))),
      );
      parts.add(part);
    }
    return 'THIX-${parts.join('-')}';
  }

  /// Construit les données du code (payload)
  static String buildPayload({
    required String code,
    required String creatorId,
    required double totalAmount,
    required String merchantId,
    required DateTime expiresAt,
  }) {
    final payload = {
      'code': code,
      'creatorId': creatorId,
      'totalAmount': totalAmount,
      'remainingAmount': totalAmount,
      'merchantId': merchantId,
      'expiresAt': expiresAt.toIso8601String(),
    };
    return base64Url.encode(utf8.encode(json.encode(payload)));
  }

  /// Décode un payload de code fractionné
  static Map<String, dynamic> decodePayload(String encodedPayload) {
    final jsonString = utf8.decode(base64Url.decode(encodedPayload));
    return json.decode(jsonString) as Map<String, dynamic>;
  }

  /// Vérifie si un code est valide (format et date d'expiration)
  static bool isValidCode(String code, Map<String, dynamic> payload) {
    // Vérifie le format du code
    final regex = RegExp(r'^THIX-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$');
    if (!regex.hasMatch(code)) return false;

    // Vérifie que le code correspond à celui dans le payload
    if (payload['code'] != code) return false;

    // Vérifie l'expiration
    final expiresAt = DateTime.parse(payload['expiresAt']);
    if (DateTime.now().isAfter(expiresAt)) return false;

    // Vérifie qu'il reste un montant à payer
    final remaining = (payload['remainingAmount'] as num).toDouble();
    if (remaining <= 0) return false;

    return true;
  }

  /// Met à jour le montant restant dans le payload
  static String updateRemainingAmount(String encodedPayload, double newRemaining) {
    final payload = decodePayload(encodedPayload);
    payload['remainingAmount'] = newRemaining;
    return base64Url.encode(utf8.encode(json.encode(payload)));
  }
}
