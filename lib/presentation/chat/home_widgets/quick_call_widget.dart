// lib/presentation/chat/home_widgets/quick_call_widget.dart
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

class QuickCallWidget {
  static const String widgetName = 'quick_call';
  
  static Future<void> update(List<Contact> contacts) async {
    final contactNames = contacts.map((c) => c.name).toList();
    final contactAvatars = contacts.map((c) => c.avatarUrl ?? '').toList();
    await HomeWidget.saveWidgetData<List<String>>('contact_names', contactNames);
    await HomeWidget.saveWidgetData<List<String>>('contact_avatars', contactAvatars);
    await HomeWidget.updateWidget(name: widgetName);
  }
  
  static Widget buildPreview() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Appels rapides',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _callContact('👤', 'Jean'),
              _callContact('👤', 'Marie'),
              _callContact('👤', 'Paul'),
              _callContact('➕', 'Ajouter'),
            ],
          ),
        ],
      ),
    );
  }
  
  static Widget _callContact(String avatar, String name) {
    return Column(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: const Color(0xFFD4AF37).withOpacity(0.1),
          child: Text(avatar, style: const TextStyle(fontSize: 20)),
        ),
        const SizedBox(height: 4),
        Text(name, style: const TextStyle(fontSize: 9)),
      ],
    );
  }
}

class Contact {
  final String id;
  final String name;
  final String? avatarUrl;
  Contact({required this.id, required this.name, this.avatarUrl});
}
