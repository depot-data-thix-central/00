// lib/providers/call_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/call_service.dart';
import '../models/call_models.dart';

class CallProvider extends ChangeNotifier {
  late CallService _service;
  
  List<Call> _callHistory = [];
  Call? _currentCall;
  bool _isInCall = false;
  bool _isMuted = false;
  bool _isSpeakerOn = true;
  bool _isVideoOn = true;
  
  CallProvider() {
    _service = CallService(Supabase.instance.client);
    _loadCallHistory();
  }
  
  // ============================================================
  // GETTERS
  // ============================================================
  
  List<Call> get callHistory => _callHistory;
  Call? get currentCall => _currentCall;
  bool get isInCall => _isInCall;
  bool get isMuted => _isMuted;
  bool get isSpeakerOn => _isSpeakerOn;
  bool get isVideoOn => _isVideoOn;
  
  // ============================================================
  // MÉTHODES
  // ============================================================
  
  Future<void> _loadCallHistory() async {
    try {
      _callHistory = await _service.getCallHistory();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading call history: $e');
    }
  }
  
  Future<void> startCall(String conversationId, String type) async {
    try {
      _currentCall = await _service.startCall(conversationId, type);
      _isInCall = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error starting call: $e');
    }
  }
  
  Future<void> acceptCall(String callId) async {
    try {
      await _service.acceptCall(callId);
      _isInCall = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error accepting call: $e');
    }
  }
  
  Future<void> rejectCall(String callId) async {
    try {
      await _service.rejectCall(callId);
      _isInCall = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error rejecting call: $e');
    }
  }
  
  Future<void> endCall() async {
    try {
      await _service.endCall(_currentCall!.id);
      _isInCall = false;
      _currentCall = null;
      await _loadCallHistory();
      notifyListeners();
    } catch (e) {
      debugPrint('Error ending call: $e');
    }
  }
  
  void toggleMute() {
    _isMuted = !_isMuted;
    _service.toggleMute(_currentCall!.id, _isMuted);
    notifyListeners();
  }
  
  void toggleSpeaker() {
    _isSpeakerOn = !_isSpeakerOn;
    _service.toggleSpeaker(_currentCall!.id, _isSpeakerOn);
    notifyListeners();
  }
  
  void toggleVideo() {
    _isVideoOn = !_isVideoOn;
    _service.toggleVideo(_currentCall!.id, _isVideoOn);
    notifyListeners();
  }
}
