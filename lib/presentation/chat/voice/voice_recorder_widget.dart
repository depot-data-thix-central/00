// lib/presentation/chat/voice/voice_recorder_widget.dart
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';

class VoiceRecorderWidget extends StatefulWidget {
  final Function(File audioFile, int duration) onRecordingComplete;
  final VoidCallback? onCancel;

  const VoiceRecorderWidget({
    super.key,
    required this.onRecordingComplete,
    this.onCancel,
  });

  @override
  State<VoiceRecorderWidget> createState() => _VoiceRecorderWidgetState();
}

class _VoiceRecorderWidgetState extends State<VoiceRecorderWidget>
    with SingleTickerProviderStateMixin {
  late AudioRecorder _recorder;
  late AnimationController _waveController;
  Timer? _timer;
  Duration _recordDuration = Duration.zero;
  bool _isRecording = false;
  bool _isPaused = false;
  String? _recordingPath;

  @override
  void initState() {
    super.initState();
    _recorder = AudioRecorder();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _waveController.dispose();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (!await _recorder.hasPermission()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission microphone refusée')),
      );
      return;
    }

    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    _recordingPath = path;

    await _recorder.start(const RecordConfig(), path: path);
    
    setState(() {
      _isRecording = true;
      _recordDuration = Duration.zero;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _isRecording && !_isPaused) {
        setState(() {
          _recordDuration = Duration(seconds: _recordDuration.inSeconds + 1);
        });
      }
    });
  }

  Future<void> _stopRecording() async {
    if (_recordingPath != null) {
      final path = await _recorder.stop();
      _timer?.cancel();
      setState(() => _isRecording = false);
      
      if (path != null && _recordDuration.inSeconds > 1) {
        final file = File(path);
        widget.onRecordingComplete(file, _recordDuration.inSeconds);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message trop court')),
        );
      }
    }
  }

  Future<void> _pauseRecording() async {
    await _recorder.pause();
    setState(() => _isPaused = true);
  }

  Future<void> _resumeRecording() async {
    await _resume();
    setState(() => _isPaused = false);
  }

  Future<void> _cancelRecording() async {
    _timer?.cancel();
    await _recorder.stop();
    if (_recordingPath != null) {
      final file = File(_recordingPath!);
      if (await file.exists()) {
        await file.delete();
      }
    }
    setState(() {
      _isRecording = false;
      _recordDuration = Duration.zero;
    });
    widget.onCancel?.call();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (!_isRecording) {
      return GestureDetector(
        onLongPress: _startRecording,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.mic, size: 18, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                'Maintenir pour enregistrer',
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37).withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animation vague
          AnimatedBuilder(
            animation: _waveController,
            builder: (context, child) {
              return Row(
                children: List.generate(4, (index) {
                  final height = 10 + (8 * _waveController.value) * (index + 1);
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: 3,
                    height: height,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              );
            },
          ),
          const SizedBox(width: 12),
          Text(
            _formatDuration(_recordDuration),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 12),
          if (_isPaused)
            IconButton(
              icon: const Icon(Icons.play_arrow, size: 18),
              onPressed: _resumeRecording,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            )
          else
            IconButton(
              icon: const Icon(Icons.pause, size: 18),
              onPressed: _pauseRecording,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          IconButton(
            icon: const Icon(Icons.stop, size: 18, color: Colors.red),
            onPressed: _stopRecording,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: Colors.grey),
            onPressed: _cancelRecording,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
