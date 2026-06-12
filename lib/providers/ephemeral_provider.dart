// lib/providers/ephemeral_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/ephemeral_service.dart';
import '../models/ephemeral_models.dart';

class EphemeralProvider extends ChangeNotifier {
  late EphemeralService _service;
  
  EphemeralSettings? _settings;
  List<ScreenshotAlert> _screenshotAlerts = [];
  bool _isEnabled = false;
  bool _isLoading = false;
  
  EphemeralProvider() {
    _service = EphemeralService(Supabase.instance.client);
  }
  
  // ============================================================
  // GETTERS
  // ============================================================
  
  EphemeralSettings? get settings => _settings;
  List<ScreenshotAlert> get screenshotAlerts => _screenshotAlerts;
  bool get isEnabled => _isEnabled;
  bool get isLoading => _isLoading;
  
  // ============================================================
  // MÉTHODES
  // ============================================================
  
  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _settings = await _service.getSettings();
      _isEnabled = _settings?.isEnabled ?? false;
      await loadScreenshotAlerts();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> loadScreenshotAlerts() async {
    try {
      _screenshotAlerts = await _service.getScreenshotAlerts();
    } catch (e) {
      debugPrint('Error loading alerts: $e');
    }
    notifyListeners();
  }
  
  Future<void> toggleEnabled(bool value) async {
    _isEnabled = value;
    if (_settings != null) {
      await _service.updateSettings(_settings!.copyWith(isEnabled: value));
      _settings = await _service.getSettings();
    }
    notifyListeners();
  }
  
  Future<void> updateDefaultDuration(int seconds) async {
    if (_settings != null) {
      await _service.updateSettings(_settings!.copyWith(defaultDuration: seconds));
      _settings = await _service.getSettings();
      notifyListeners();
    }
  }
  
  Future<void> updateNotifyScreenshot(bool value) async {
    if (_settings != null) {
      await _service.updateSettings(_settings!.copyWith(notifyScreenshot: value));
      _settings = await _service.getSettings();
      notifyListeners();
    }
  }
  
  void reportScreenshot(String messageId) {
    // Implémenter le signalement de capture d'écran
  }
}
