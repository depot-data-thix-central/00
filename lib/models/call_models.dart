// lib/models/call_models.dart
class Call {
  final String id;
  final String callerId;
  final String callerName;
  final String? callerAvatar;
  final String receiverId;
  final String receiverName;
  final String? receiverAvatar;
  final String type; // 'audio', 'video'
  final String status; // 'missed', 'answered', 'rejected', 'cancelled'
  final int duration; // seconds
  final DateTime startedAt;
  final DateTime? endedAt;

  Call({
    required this.id,
    required this.callerId,
    required this.callerName,
    this.callerAvatar,
    required this.receiverId,
    required this.receiverName,
    this.receiverAvatar,
    required this.type,
    required this.status,
    required this.duration,
    required this.startedAt,
    this.endedAt,
  });
}

class CallParticipant {
  final String id;
  final String name;
  final String? avatarUrl;
  final bool isSpeaking;
  final bool isMuted;
  final bool isVideoOn;

  CallParticipant({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.isSpeaking = false,
    this.isMuted = false,
    this.isVideoOn = true,
  });
}
