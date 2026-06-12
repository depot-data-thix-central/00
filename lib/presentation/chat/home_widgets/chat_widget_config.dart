// lib/presentation/chat/home_widgets/chat_widget_config.dart
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

class ChatWidgetConfig {
  static const List<String> widgetNames = [
    RecentConversationWidget.widgetName,
    StatusWidget.widgetName,
    QuickCallWidget.widgetName,
    PollWidget.widgetName,
  ];
  
  static Future<void> registerAll() async {
    await HomeWidget.registerBackgroundCallback(handleBackground);
  }
  
  static Future<void> handleBackground(Uri? uri) async {
    if (uri?.host == 'open_conversation') {
      final conversationId = uri?.queryParameters['id'];
      // Ouvrir la conversation dans l'app
      // À implémenter avec deep linking
    }
  }
  
  static Widget buildConfigPage() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Widgets maison',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        children: [
          _buildWidgetCard(
            'Conversation récente',
            'Affiche votre dernière conversation',
            RecentConversationWidget.buildPreview(),
            () => _addWidget(RecentConversationWidget.widgetName),
          ),
          _buildWidgetCard(
            'Statut',
            'Affiche votre statut et les mises à jour',
            StatusWidget.buildPreview(),
            () => _addWidget(StatusWidget.widgetName),
          ),
          _buildWidgetCard(
            'Appel rapide',
            'Appelez vos contacts favoris en un clic',
            QuickCallWidget.buildPreview(),
            () => _addWidget(QuickCallWidget.widgetName),
          ),
          _buildWidgetCard(
            'Sondage',
            'Participez aux sondages en cours',
            PollWidget.buildPreview(),
            () => _addWidget(PollWidget.widgetName),
          ),
        ],
      ),
    );
  }
  
  static Widget _buildWidgetCard(String title, String description, Widget preview, VoidCallback onAdd) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(description, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 12),
          preview,
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('Ajouter le widget', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
  
  static Future<void> _addWidget(String name) async {
    // Demander à l'utilisateur d'ajouter le widget
    // Cette fonction est spécifique à iOS et Android
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ajoutez le widget $name depuis l\'écran d\'accueil'),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
