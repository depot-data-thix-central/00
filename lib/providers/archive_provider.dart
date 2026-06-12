// lib/providers/archive_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../services/archive_service.dart';
import '../models/archive_models.dart';

class ArchiveProvider extends ChangeNotifier {
  late ArchiveService _service;
  
  List<ArchivedConversation> _archivedConversations = [];
  List<ArchivedMedia> _archivedMedia = [];
  List<ArchivedFile> _archivedFiles = [];
  List<ArchivedLink> _archivedLinks = [];
  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  
  ArchiveProvider() {
    _service = ArchiveService(Supabase.instance.client);
  }
  
  // ============================================================
  // GETTERS
  // ============================================================
  
  List<ArchivedConversation> get archivedConversations => _archivedConversations;
  List<ArchivedMedia> get archivedMedia => _archivedMedia;
  List<ArchivedFile> get archivedFiles => _archivedFiles;
  List<ArchivedLink> get archivedLinks => _archivedLinks;
  List<dynamic> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  
  // ============================================================
  // MÉTHODES
  // ============================================================
  
  Future<void> loadArchivedConversations() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _archivedConversations = await _service.getArchivedConversations();
    } catch (e) {
      debugPrint('Error loading archived conversations: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> loadArchivedMedia() async {
    try {
      _archivedMedia = await _service.getArchivedMedia();
    } catch (e) {
      debugPrint('Error loading archived media: $e');
    }
    notifyListeners();
  }
  
  Future<void> loadArchivedFiles() async {
    try {
      _archivedFiles = await _service.getArchivedFiles();
    } catch (e) {
      debugPrint('Error loading archived files: $e');
    }
    notifyListeners();
  }
  
  Future<void> loadArchivedLinks() async {
    try {
      _archivedLinks = await _service.getArchivedLinks();
    } catch (e) {
      debugPrint('Error loading archived links: $e');
    }
    notifyListeners();
  }
  
  Future<void> unarchiveConversation(String id) async {
    try {
      await _service.unarchiveConversation(id);
      await loadArchivedConversations();
    } catch (e) {
      debugPrint('Error unarchiving conversation: $e');
    }
  }
  
  Future<void> unarchiveMedia(String id) async {
    try {
      await _service.unarchiveMedia(id);
      await loadArchivedMedia();
    } catch (e) {
      debugPrint('Error unarchiving media: $e');
    }
  }
  
  Future<void> unarchiveFile(String id) async {
    try {
      await _service.unarchiveFile(id);
      await loadArchivedFiles();
    } catch (e) {
      debugPrint('Error unarchiving file: $e');
    }
  }
  
  Future<void> unarchiveLink(String id) async {
    try {
      await _service.unarchiveLink(id);
      await loadArchivedLinks();
    } catch (e) {
      debugPrint('Error unarchiving link: $e');
    }
  }
  
  Future<void> deleteArchiveItem(String id) async {
    try {
      await _service.deleteArchiveItem(id);
      await loadArchivedConversations();
      await loadArchivedMedia();
      await loadArchivedFiles();
      await loadArchivedLinks();
    } catch (e) {
      debugPrint('Error deleting archive item: $e');
    }
  }
  
  Future<void> searchArchives({
    String? query,
    String? type,
    String? dateRange,
    String? sender,
    String? chat,
    bool? hasMedia,
  }) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _searchResults = await _service.search(
        query: query,
        type: type,
        dateRange: dateRange,
        sender: sender,
        chat: chat,
        hasMedia: hasMedia,
      );
    } catch (e) {
      debugPrint('Error searching archives: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<String?> exportConversation({
    required String conversationId,
    required String format,
    required bool includeMedia,
    required bool includeDate,
    required bool includeTime,
    required String dateRange,
  }) async {
    try {
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/export_$conversationId.$format';
      final file = File(filePath);
      
      String content = 'Export de la conversation\n';
      content += 'Date: ${DateTime.now()}\n';
      content += '=' * 50 + '\n\n';
      
      await file.writeAsString(content);
      return filePath;
    } catch (e) {
      debugPrint('Error exporting conversation: $e');
      return null;
    }
  }
}
