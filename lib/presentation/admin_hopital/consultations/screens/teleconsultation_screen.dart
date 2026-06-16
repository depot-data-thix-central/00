// 📁 lib/presentation/admin_hopital/consultations/screens/teleconsultation_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../common/widgets/admin_gradient_button.dart';
import '../../../common/widgets/admin_status_badge.dart';

class TeleconsultationScreen extends ConsumerStatefulWidget {
  final String? patientId;
  final String? patientName;
  final String? appointmentId;

  const TeleconsultationScreen({
    Key? key,
    this.patientId,
    this.patientName,
    this.appointmentId,
  }) : super(key: key);

  @override
  ConsumerState<TeleconsultationScreen> createState() => _TeleconsultationScreenState();
}

class _TeleconsultationScreenState extends ConsumerState<TeleconsultationScreen> {
  bool _isCallActive = false;
  bool _isMuted = false;
  bool _isVideoOn = true;
  bool _isRecording = false;
  bool _isScreenSharing = false;
  int _callDuration = 0;

  @override
  void initState() {
    super.initState();
    // Simuler le démarrage de l'appel
    _startCall();
  }

  void _startCall() {
    setState(() {
      _isCallActive = true;
      _callDuration = 0;
    });
    // Simuler un minuteur
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || !_isCallActive) return false;
      setState(() => _callDuration++);
      return true;
    });
  }

  void _endCall() {
    setState(() => _isCallActive = false);
    // Naviguer vers le résumé
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final patientName = widget.patientName ?? 'Patient';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey.shade900, Colors.grey.shade800],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Barre supérieure
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        if (_isCallActive) {
                          _endCall();
                        } else {
                          context.pop();
                        }
                      },
                    ),
                    const Spacer(),
                    Text(
                      _isCallActive ? 'En appel...' : 'En attente...',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const Spacer(),
                    if (_isCallActive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatDuration(_callDuration),
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              // Vidéo principale (simulée)
              Expanded(
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade700,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 12),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.green.shade300,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              patientName.isNotEmpty ? patientName[0].toUpperCase() : 'P',
                              style: const TextStyle(
                                fontSize: 40,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          patientName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AdminStatusBadge(
                          status: _isCallActive ? StatusType.active : StatusType.pending,
                          customLabel: _isCallActive ? 'En cours' : 'Connexion...',
                        ),
                        const SizedBox(height: 20),
                        // Miniature (caméra du médecin)
                        Container(
                          width: 120,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade600,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: const Center(
                            child: Icon(Icons.videocam, color: Colors.white54, size: 30),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Contrôles
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildControlButton(
                          icon: _isMuted ? Icons.mic_off : Icons.mic,
                          label: _isMuted ? 'Micro' : 'Micro',
                          active: !_isMuted,
                          onPressed: () => setState(() => _isMuted = !_isMuted),
                        ),
                        _buildControlButton(
                          icon: _isVideoOn ? Icons.videocam : Icons.videocam_off,
                          label: _isVideoOn ? 'Caméra' : 'Caméra',
                          active: _isVideoOn,
                          onPressed: () => setState(() => _isVideoOn = !_isVideoOn),
                        ),
                        _buildControlButton(
                          icon: _isScreenSharing ? Icons.present_to_all : Icons.screenshot,
                          label: 'Partage',
                          active: _isScreenSharing,
                          onPressed: () => setState(() => _isScreenSharing = !_isScreenSharing),
                        ),
                        _buildControlButton(
                          icon: Icons.chat,
                          label: 'Chat',
                          active: false,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Chat en développement'), backgroundColor: Colors.blue),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.red.withOpacity(0.4), blurRadius: 12),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.call_end, color: Colors.white, size: 28),
                            onPressed: _endCall,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade700,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.more_horiz, color: Colors.white, size: 24),
                            onPressed: () {
                              // Afficher plus d'options (enregistrement, etc.)
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: active ? Colors.green : Colors.grey.shade700,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white, size: 22),
            onPressed: onPressed,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: active ? Colors.green : Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
