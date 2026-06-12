// lib/presentation/chat/archive/archive_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../providers/archive_provider.dart';
import '../../../models/archive_models.dart';
import 'archive_list_item.dart';
import 'advanced_search_sheet.dart';

class ArchivePage extends StatefulWidget {
  const ArchivePage({super.key});

  @override
  State<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String _searchQuery = '';
  
  final List<Map<String, dynamic>> _tabs = [
    {'label': 'Conversations', 'icon': Icons.chat},
    {'label': 'Médias', 'icon': Icons.image},
    {'label': 'Fichiers', 'icon': Icons.insert_drive_file},
    {'label': 'Liens', 'icon': Icons.link},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadArchives();
  }

  Future<void> _loadArchives() async {
    final provider = Provider.of<ArchiveProvider>(context, listen: false);
    await provider.loadArchivedConversations();
    setState(() => _isLoading = false);
  }

  void _showSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, __) => const AdvancedSearchSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ArchiveProvider>(context);
    final conversations = provider.archivedConversations;
    final media = provider.archivedMedia;
    final files = provider.archivedFiles;
    final links = provider.archivedLinks;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Archives',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 20, color: Color(0xFFD4AF37)),
            onPressed: _showSearch,
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, size: 20),
            itemBuilder: (context) => [
              const PopupMenuItem(child: Text('Tout sélectionner', style: TextStyle(fontSize: 13))),
              const PopupMenuItem(child: Text('Tout désarchiver', style: TextStyle(fontSize: 13))),
              const PopupMenuItem(child: Text('Supprimer tout', style: TextStyle(fontSize: 13))),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFD4AF37),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFD4AF37),
          tabs: _tabs.map((tab) => Tab(text: tab['label'], icon: Icon(tab['icon'], size: 18))).toList(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildConversationsTab(conversations),
                _buildMediaTab(media),
                _buildFilesTab(files),
                _buildLinksTab(links),
              ],
            ),
    );
  }

  Widget _buildConversationsTab(List<ArchivedConversation> conversations) {
    if (conversations.isEmpty) {
      return _buildEmptyState(
        Icons.chat_bubble_outline,
        'Aucune conversation archivée',
        'Les conversations que vous archivez apparaîtront ici',
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: conversations.length,
      itemBuilder: (context, index) => ArchiveListItem(
        item: conversations[index],
        onTap: () => _openConversation(conversations[index]),
        onUnarchive: () => _unarchiveConversation(conversations[index].id),
        onDelete: () => _deleteArchiveItem(conversations[index].id),
      ),
    );
  }

  Widget _buildMediaTab(List<ArchivedMedia> media) {
    if (media.isEmpty) {
      return _buildEmptyState(
        Icons.image_outlined,
        'Aucun média archivé',
        'Les photos et vidéos que vous archivez apparaîtront ici',
      );
    }
    
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: media.length,
      itemBuilder: (context, index) => _buildMediaItem(media[index]),
    );
  }

  Widget _buildMediaItem(ArchivedMedia media) {
    return GestureDetector(
      onTap: () => _viewMedia(media),
      onLongPress: () => _showMediaOptions(media),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          image: media.thumbnailUrl != null
              ? DecorationImage(image: NetworkImage(media.thumbnailUrl!), fit: BoxFit.cover)
              : null,
        ),
        child: Stack(
          children: [
            if (media.type == 'video')
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.play_arrow, size: 12, color: Colors.white),
                ),
              ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _unarchiveMedia(media.id),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.unarchive, size: 12, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilesTab(List<ArchivedFile> files) {
    if (files.isEmpty) {
      return _buildEmptyState(
        Icons.insert_drive_file_outlined,
        'Aucun fichier archivé',
        'Les documents que vous archivez apparaîtront ici',
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: files.length,
      itemBuilder: (context, index) => _buildFileItem(files[index]),
    );
  }

  Widget _buildFileItem(ArchivedFile file) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getFileColor(file.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_getFileIcon(file.type), size: 24, color: _getFileColor(file.type)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      _formatFileSize(file.size),
                      style: const TextStyle(fontSize: 9, color: Colors.grey),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(file.archivedAt),
                      style: const TextStyle(fontSize: 9, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.unarchive, size: 18, color: Color(0xFFD4AF37)),
            onPressed: () => _unarchiveFile(file.id),
          ),
          IconButton(
            icon: const Icon(Icons.share, size: 16, color: Colors.grey),
            onPressed: () => _shareFile(file),
          ),
        ],
      ),
    );
  }

  Widget _buildLinksTab(List<ArchivedLink> links) {
    if (links.isEmpty) {
      return _buildEmptyState(
        Icons.link_off,
        'Aucun lien archivé',
        'Les liens que vous archivez apparaîtront ici',
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: links.length,
      itemBuilder: (context, index) => _buildLinkItem(links[index]),
    );
  }

  Widget _buildLinkItem(ArchivedLink link) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              image: link.previewImage != null
                  ? DecorationImage(image: NetworkImage(link.previewImage!), fit: BoxFit.cover)
                  : null,
            ),
            child: link.previewImage == null
                ? Icon(Icons.link, size: 24, color: Colors.grey[400])
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  link.title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  link.url,
                  style: const TextStyle(fontSize: 10, color: Color(0xFFD4AF37)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(link.archivedAt),
                  style: const TextStyle(fontSize: 9, color: Colors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.unarchive, size: 18, color: Color(0xFFD4AF37)),
            onPressed: () => _unarchiveLink(link.id),
          ),
          IconButton(
            icon: const Icon(Icons.open_in_browser, size: 16, color: Colors.grey),
            onPressed: () => _openLink(link.url),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(IconData icon, String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _showMediaOptions(ArchivedMedia media) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.unarchive, size: 20),
              title: const Text('Désarchiver', style: TextStyle(fontSize: 13)),
              onTap: () {
                Navigator.pop(context);
                _unarchiveMedia(media.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, size: 20, color: Colors.red),
              title: const Text('Supprimer définitivement', style: TextStyle(fontSize: 13, color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteArchiveItem(media.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openConversation(ArchivedConversation conversation) {
    // Naviguer vers la conversation
  }

  void _viewMedia(ArchivedMedia media) {
    // Afficher le média en plein écran
  }

  void _unarchiveConversation(String id) async {
    final provider = Provider.of<ArchiveProvider>(context, listen: false);
    await provider.unarchiveConversation(id);
    _loadArchives();
  }

  void _unarchiveMedia(String id) async {
    final provider = Provider.of<ArchiveProvider>(context, listen: false);
    await provider.unarchiveMedia(id);
    _loadArchives();
  }

  void _unarchiveFile(String id) async {
    final provider = Provider.of<ArchiveProvider>(context, listen: false);
    await provider.unarchiveFile(id);
    _loadArchives();
  }

  void _unarchiveLink(String id) async {
    final provider = Provider.of<ArchiveProvider>(context, listen: false);
    await provider.unarchiveLink(id);
    _loadArchives();
  }

  void _deleteArchiveItem(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer', style: TextStyle(fontSize: 16)),
        content: const Text('Cette action est irréversible. Voulez-vous vraiment supprimer ?', style: TextStyle(fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler', style: TextStyle(fontSize: 12))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final provider = Provider.of<ArchiveProvider>(context, listen: false);
      await provider.deleteArchiveItem(id);
      _loadArchives();
    }
  }

  void _shareFile(ArchivedFile file) {
    // Partager le fichier
  }

  void _openLink(String url) async {
    // Ouvrir le lien
  }

  IconData _getFileIcon(String type) {
    switch (type) {
      case 'pdf': return Icons.picture_as_pdf;
      case 'doc':
      case 'docx': return Icons.description;
      case 'xls':
      case 'xlsx': return Icons.table_chart;
      case 'ppt':
      case 'pptx': return Icons.slideshow;
      default: return Icons.insert_drive_file;
    }
  }

  Color _getFileColor(String type) {
    switch (type) {
      case 'pdf': return Colors.red;
      case 'doc':
      case 'docx': return Colors.blue;
      case 'xls':
      case 'xlsx': return Colors.green;
      case 'ppt':
      case 'pptx': return Colors.orange;
      default: return Colors.grey;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return "Aujourd'hui";
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} jours';
    return DateFormat('dd/MM/yyyy').format(date);
  }
}
