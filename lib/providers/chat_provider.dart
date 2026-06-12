// lib/providers/chat_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

import '../services/chat_service.dart';
import '../models/chat_models.dart';

class ChatProvider extends ChangeNotifier {
  // Services
  late ChatService _service;
  
  // Données
  List<Conversation> _conversations = [];
  List<ChatMessage> _messages = [];
  List<Story> _stories = [];
  List<Space> _spaces = [];
  ChatStats _stats = ChatStats.empty();
  
  // États
  bool _isLoading = false;
  bool _isTyping = false;
  String? _error;
  
  // Realtime
  RealtimeChannel? _messagesChannel;
  Timer? _typingTimer;
  
  // Getters
  List<Conversation> get conversations => _conversations;
  List<ChatMessage> get messages => _messages;
  List<Story> get stories => _stories;
  List<Space> get spaces => _spaces;
  ChatStats get stats => _stats;
  bool get isLoading => _isLoading;
  bool get isTyping => _isTyping;
  String? get error => _error;
  
  // Constructeur
  ChatProvider() {
    _service = ChatService(Supabase.instance.client);
    _initRealtime();
  }
  
  // Méthodes principales
  Future<void> loadConversations() async { ... }
  Future<void> loadMessages(String conversationId) async { ... }
  Future<void> sendMessage(String conversationId, String content) async { ... }
  Future<void> sendMedia(String conversationId, String filePath, String type) async { ... }
  Future<void> toggleLike(String messageId) async { ... }
  Future<void> addReaction(String messageId, String emoji) async { ... }
  Future<void> pinMessage(String conversationId, String messageId) async { ... }
  Future<void> markMessagesAsRead(String conversationId) async { ... }
  void sendTypingStatus(String conversationId, bool isTyping) { ... }
  void initRealtime() { ... }
  void dispose() { ... }
}
