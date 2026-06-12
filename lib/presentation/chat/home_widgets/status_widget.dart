// lib/presentation/chat/home_widgets/status_widget.dart
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

class StatusWidget {
  static const String widgetName = 'chat_status';
  
  static Future<void> update(String status, int unreadCount) async {
    await HomeWidget.saveWidgetData<String>('status', status);
    await HomeWidget.saveWidgetData<int>('unread_count', unreadCount);
    await HomeWidget.updateWidget(name: widgetName);
  }
  
  static Widget buildPreview() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD4AF37), width: 2),
            ),
            child: const CircleAvatar(
              child: Icon(Icons.person, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mon statut',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Ajouter une mise à jour',
                  style: TextStyle(fontSize: 9, color: Colors.grey),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '2 nouveaux',
                    style: TextStyle(fontSize: 8, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.circle, size: 14, color: Color(0xFFD4AF37)),
        ],
      ),
    );
  }
}
