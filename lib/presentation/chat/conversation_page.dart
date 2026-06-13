// lib/presentation/chat/conversation_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thix_id/presentation/chat/core/chat_bloc.dart';
import 'package:thix_id/presentation/chat/core/chat_events.dart';
import 'package:thix_id/presentation/chat/core/chat_states.dart';
import 'package:thix_id/presentation/chat/widgets/chat_bubble.dart';
import 'package:thix_id/presentation/chat/widgets/chat_input_bar.dart';
import 'package:thix_id/presentation/chat/widgets/pinned_message.dart';
import 'package:thix_id/presentation/chat/online_status/typing_indicator.dart';

class ConversationPage extends StatefulWidget {
  final String conversationId;
  const ConversationPage({Key? key, required this.conversationId}) : super(key: key);

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  late final ChatBloc _chatBloc;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _chatBloc = context.read<ChatBloc>();
    _chatBloc.add(LoadMessages(widget.conversationId));
    _chatBloc.add(StartTyping(widget.conversationId));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _chatBloc.add(StopTyping(widget.conversationId));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<ChatBloc, ChatState>(
          buildWhen: (previous, current) => current is ConversationDetailsLoaded,
          builder: (context, state) {
            final name = state is ConversationDetailsLoaded ? state.conversationName : 'Chat';
            return Text(name);
          },
        ),
        actions: [
          IconButton(icon: const Icon(Icons.phone_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.videocam_outlined), onPressed: () {}),
        ],
      ),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is MessageSentSuccess) {
            _messageController.clear();
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          } else if (state is ConfidentialMessageUnlocked) {
            // Optionnel: afficher un toast
          }
        },
        builder: (context, state) {
          if (state is ChatLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MessagesLoaded && state.conversationId == widget.conversationId) {
            return Column(
              children: [
                if (state.pinnedMessage != null)
                  PinnedMessage(
                    message: state.pinnedMessage!,
                    onTap: () {},
                  ),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final msg = state.messages[index];
                      final isMe = msg.senderId == _chatBloc.currentUserId;
                      return ChatBubble(
                        message: msg.content ?? '',
                        isMe: isMe,
                        time: _formatTime(msg.sentAt),
                        reactionsCount: msg.reactions.length,
                        onReactionTap: () => _showReactionPicker(msg.id),
                        isVoiceMessage: msg.type == 'voice',
                        voiceDuration: msg.durationSeconds,
                        onConfidentialTap: msg.type == 'confidential'
                            ? () => _showConfidentialDialog(msg)
                            : null,
                      );
                    },
                  ),
                ),
                if (state is TypingState && state.typingUsers.isNotEmpty)
                  TypingIndicator(users: state.typingUsers),
                ChatInputBar(
                  controller: _messageController,
                  onSendText: (text) {
                    if (text.trim().isNotEmpty) {
                      _chatBloc.add(SendMessage(
                        conversationId: widget.conversationId,
                        type: 'text',
                        content: text,
                      ));
                    }
                  },
                  onSendVoice: (path) {
                    _chatBloc.add(SendMessage(
                      conversationId: widget.conversationId,
                      type: 'voice',
                      mediaUrl: path,
                    ));
                  },
                  onAttachment: (file) {
                    _chatBloc.add(SendMessage(
                      conversationId: widget.conversationId,
                      type: 'image',
                      mediaUrl: file.path,
                    ));
                  },
                  onEphemeral: () => _showEphemeralDialog(),
                  onConfidential: () => _showConfidentialComposer(),
                ),
              ],
            );
          } else if (state is ChatError) {
            return Center(child: Text('Erreur : ${state.message}'));
          }
          return const Center(child: Text('Aucun message'));
        },
      ),
    );
  }

  void _showReactionPicker(String messageId) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ReactionPicker(
        onReactionSelected: (reaction) {
          _chatBloc.add(AddReaction(messageId, reaction));
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showConfidentialDialog(Message msg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Message confidentiel'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ce message nécessite un code pour être déverrouillé.'),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Entrez le code',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (code) {
                _chatBloc.add(UnlockConfidentialMessage(msg.id, code));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEphemeralDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Message éphémère'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choisissez la durée d\'auto-destruction'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [5, 10, 30, 60].map((sec) {
                return ElevatedButton(
                  onPressed: () {
                    final content = _messageController.text;
                    _messageController.clear();
                    _chatBloc.add(SendEphemeralMessage(
                      conversationId: widget.conversationId,
                      content: content.isNotEmpty ? content : null,
                      durationSeconds: sec,
                    ));
                    Navigator.pop(context);
                  },
                  child: Text('$sec s'),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfidentialComposer() {
    final codeController = TextEditingController();
    final messageController = TextEditingController();
    bool useBiometric = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Message confidentiel'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: messageController,
                decoration: const InputDecoration(hintText: 'Votre message'),
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: codeController,
                decoration: const InputDecoration(hintText: 'Code secret (4-6 chiffres)'),
                obscureText: true,
                keyboardType: TextInputType.number,
              ),
              Row(
                children: [
                  Checkbox(
                    value: useBiometric,
                    onChanged: (val) => setState(() => useBiometric = val ?? false),
                  ),
                  const Text('Utiliser biométrie (empreinte / visage)'),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                final content = messageController.text;
                final code = codeController.text;
                if (content.isNotEmpty && (useBiometric || code.isNotEmpty)) {
                  _chatBloc.add(SendConfidentialMessage(
                    conversationId: widget.conversationId,
                    content: content,
                    code: code,
                    isBiometric: useBiometric,
                  ));
                  Navigator.pop(context);
                }
              },
              child: const Text('Envoyer'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
