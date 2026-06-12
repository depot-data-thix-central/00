// lib/presentation/chat/voice/transcript_view.dart
import 'package:flutter/material.dart';

class TranscriptView extends StatefulWidget {
  final String transcript;
  final bool isFromMe;
  final VoidCallback? onToggle;

  const TranscriptView({
    super.key,
    required this.transcript,
    this.isFromMe = false,
    this.onToggle,
  });

  @override
  State<TranscriptView> createState() => _TranscriptViewState();
}

class _TranscriptViewState extends State<TranscriptView> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final maxLines = _isExpanded ? null : 2;
    
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: widget.isFromMe
            ? Colors.white.withOpacity(0.15)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.subtitles, size: 12, color: Colors.grey),
              const SizedBox(width: 4),
              const Text(
                'Transcription',
                style: TextStyle(fontSize: 9, color: Colors.grey),
              ),
              const Spacer(),
              if (widget.transcript.length > 100)
                GestureDetector(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  child: Text(
                    _isExpanded ? 'Voir moins' : 'Voir plus',
                    style: const TextStyle(fontSize: 9, color: Color(0xFFD4AF37)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            widget.transcript,
            style: TextStyle(
              fontSize: 11,
              color: widget.isFromMe ? Colors.white70 : Colors.black87,
              height: 1.4,
            ),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
