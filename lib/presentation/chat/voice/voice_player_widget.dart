// lib/presentation/chat/voice/voice_player_widget.dart
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

class VoicePlayerWidget extends StatefulWidget {
  final String audioUrl;
  final int duration;
  final bool isFromMe;

  const VoicePlayerWidget({
    super.key,
    required this.audioUrl,
    required this.duration,
    this.isFromMe = false,
  });

  @override
  State<VoicePlayerWidget> createState() => _VoicePlayerWidgetState();
}

class _VoicePlayerWidgetState extends State<VoicePlayerWidget> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _playbackSpeed = 1.0;
  Timer? _progressTimer;

  @override
  void initState() {
    super.initState();
    _duration = Duration(seconds: widget.duration);
    _setupListeners();
  }

  void _setupListeners() {
    _player.onPositionChanged.listen((pos) {
      if (mounted) {
        setState(() => _position = pos);
      }
    });
    
    _player.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
        _player.seek(Duration.zero);
      }
    });
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _player.pause();
      setState(() => _isPlaying = false);
    } else {
      setState(() => _isLoading = true);
      try {
        await _player.play(UrlSource(widget.audioUrl));
        setState(() => _isPlaying = true);
      } catch (e) {
        debugPrint('Error playing audio: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _seekTo(double value) async {
    final newPosition = Duration(seconds: value.toInt());
    await _player.seek(newPosition);
    setState(() => _position = newPosition);
  }

  Future<void> _setPlaybackSpeed(double speed) async {
    setState(() => _playbackSpeed = speed);
    await _player.setPlaybackRate(speed);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get _progress => _duration.inSeconds > 0
      ? _position.inSeconds / _duration.inSeconds
      : 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Bouton play/pause
            GestureDetector(
              onTap: _togglePlay,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: widget.isFromMe ? Colors.white : const Color(0xFFD4AF37),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: _isLoading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: widget.isFromMe ? const Color(0xFFD4AF37) : Colors.white,
                          ),
                        )
                      : Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          size: 18,
                          color: widget.isFromMe ? const Color(0xFFD4AF37) : Colors.white,
                        ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Timeline
            Expanded(
              child: Column(
                children: [
                  Slider(
                    value: _position.inSeconds.toDouble(),
                    max: _duration.inSeconds.toDouble(),
                    activeColor: const Color(0xFFD4AF37),
                    inactiveColor: Colors.grey[300],
                    onChanged: _seekTo,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_position),
                        style: const TextStyle(fontSize: 9, color: Colors.grey),
                      ),
                      Text(
                        _formatDuration(_duration),
                        style: const TextStyle(fontSize: 9, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        // Vitesse de lecture
        if (_isPlaying)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                const Icon(Icons.speed, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                ...['0.5x', '1x', '1.5x', '2x'].map((speed) {
                  final value = double.parse(speed.replaceAll('x', ''));
                  final isSelected = _playbackSpeed == value;
                  return GestureDetector(
                    onTap: () => _setPlaybackSpeed(value),
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFD4AF37) : Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        speed,
                        style: TextStyle(
                          fontSize: 9,
                          color: isSelected ? Colors.white : Colors.grey,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
      ],
    );
  }
}
