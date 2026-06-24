import 'package:flutter/material.dart';
import '../../services/thix_money/card_service.dart';
import '../../models/thix_money/nfc_card_model.dart';

class CardProvider extends ChangeNotifier {
  final CardService _cardService = CardService();
  
  NfcCardModel? _card;
  bool _isLoading = false;

  NfcCardModel? get card => _card;
  bool get isLoading => _isLoading;
  bool get hasCard => _card != null;
  bool get isCardActive => _card?.isActive ?? false;

  Future<void> loadCard() async {
    _isLoading = true;
    notifyListeners();
    try {
      _card = await _cardService.getCard();
    } catch (e) {
      debugPrint('CardProvider loadCard error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> activateCard(String pin) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _cardService.activateCard(pin);
      if (success) await loadCard();
      return success;
    } catch (e) {
      debugPrint('CardProvider activateCard error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> blockCard() async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _cardService.blockCard();
      if (success) await loadCard();
      return success;
    } catch (e) {
      debugPrint('CardProvider blockCard error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> setPin(String oldPin, String newPin) async {
    _isLoading = true;
    notifyListeners();
    try {
      return await _cardService.changePin(oldPin, newPin);
    } catch (e) {
      debugPrint('CardProvider setPin error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> setLimitWithoutPin(double limit) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _cardService.setLimitWithoutPin(limit);
      if (success) await loadCard();
      return success;
    } catch (e) {
      debugPrint('CardProvider setLimitWithoutPin error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
