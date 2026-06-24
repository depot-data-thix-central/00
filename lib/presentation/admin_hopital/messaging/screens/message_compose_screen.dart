// 📁 lib/presentation/admin_hopital/messaging/screens/message_compose_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/message_composer.dart';
import '../../common/widgets/admin_loading_overlay.dart';
import '../../common/providers/admin_staff_provider.dart';

class MessageComposeScreen extends ConsumerStatefulWidget {
  final String? recipient;
  final String? subject;
  final String? body;

  const MessageComposeScreen({
    Key? key,
    this.recipient,
    this.subject,
    this.body,
  }) : super(key: key);

  @override
  ConsumerState<MessageComposeScreen> createState() => _MessageComposeScreenState();
}

class _MessageComposeScreenState extends ConsumerState<MessageComposeScreen> {
  bool _isSending = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau message'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            _showCancelConfirmation();
          },
        ),
        actions: [
          TextButton(
            onPressed: _isSending ? null : _sendMessage,
            child: const Text(
              'Envoyer',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
      body: AdminLoadingOverlay(
        isLoading: _isSending,
        message: 'Envoi en cours...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: MessageComposer(
            initialRecipient: widget.recipient,
            initialSubject: widget.subject,
            initialBody: widget.body,
            onSend: (data) async {
              setState(() => _isSending = true);
              try {
                // Simuler l'envoi
                await Future.delayed(const Duration(seconds: 2));
                // Ici, appeler le provider pour sauvegarder le message
                // await ref.read(adminMessageProvider.notifier).sendMessage(data);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Message envoyé avec succès'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  context.pop();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur lors de l\'envoi: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } finally {
                if (mounted) setState(() => _isSending = false);
              }
            },
          ),
        ),
      ),
    );
  }

  void _showCancelConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Annuler le message'),
        content: const Text(
          'Êtes-vous sûr de vouloir annuler ce message ? Il ne sera pas sauvegardé.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continuer la rédaction'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Annuler le message'),
          ),
        ],
      ),
    );
  }
}
