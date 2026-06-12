// lib/providers/location_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

import '../services/location_service.dart';
import '../models/location_models.dart';

class LocationProvider extends ChangeNotifier {
  late LocationService _service;
  
  List<LiveLocation> _liveLocations = [];
  bool _isLoading = false;
  Timer? _refreshTimer;
  
  LocationProvider() {
    _service = LocationService(Supabase.instance.client);
    _startAutoRefresh();
  }
  
  // ============================================================
  // GETTERS
  // ============================================================
  
  List<LiveLocation> get liveLocations => _liveLocations;
  bool get isLoading => _isLoading;
  
  // ============================================================
  // MÉTHODES
  // ============================================================
  
  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      refreshLocations();
    });
  }
  
  Future<void> refreshLocations() async {
    await loadLiveLocations();
  }
  
  Future<void> loadLiveLocations() async {
    try {
      final locations = await _service.getActiveLocations();
      _liveLocations = locations;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading locations: $e');
    }
  }
  
  Future<LiveLocation?> getLiveLocation(String id) async {
    return await _service.getLocationById(id);
  }
  
  Future<bool> shareLiveLocation({
    required String conversationId,
    required double latitude,
    required double longitude,
    required int durationMinutes,
    String? address,
  }) async {
    try {
      final expiresAt = durationMinutes > 0
          ? DateTime.now().add(Duration(minutes: durationMinutes))
          : null;
      
      await _service.createLocation(
        conversationId: conversationId,
        latitude: latitude,
        longitude: longitude,
        expiresAt: expiresAt,
        address: address,
      );
      
      await loadLiveLocations();
      return true;
    } catch (e) {
      debugPrint('Error sharing location: $e');
      return false;
    }
  }
  
  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
