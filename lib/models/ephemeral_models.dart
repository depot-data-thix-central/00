// lib/models/ephemeral_models.dart
class EphemeralSettings {
  final String id;
  final String userId;
  final int defaultDuration;
  final bool notifyScreenshot;
  final bool isEnabled;

  EphemeralSettings({
    required this.id,
    required this.userId,
    required this.defaultDuration,
    required this.notifyScreenshot,
    required this.isEnabled,
  });

  factory EphemeralSettings.fromJson(Map<String, dynamic> json) {
    return EphemeralSettings(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      defaultDuration: json['default_duration'] as int? ?? 30,
      notifyScreenshot: json['notify_screenshot'] as bool? ?? true,
      isEnabled: json['is_enabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'default_duration': defaultDuration,
      'notify_screenshot': notifyScreenshot,
      'is_enabled': isEnabled,
    };
  }

  EphemeralSettings copyWith({
    String? id,
    String? userId,
    int? defaultDuration,
    bool? notifyScreenshot,
    bool? isEnabled,
  }) {
    return EphemeralSettings(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      defaultDuration: defaultDuration ?? this.defaultDuration,
      notifyScreenshot: notifyScreenshot ?? this.notifyScreenshot,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}

class ScreenshotAlert {
  final String id;
  final String messageId;
  final String userId;
  final String capturedBy;
  final String userName;
  final DateTime capturedAt;

  ScreenshotAlert({
    required this.id,
    required this.messageId,
    required this.userId,
    required this.capturedBy,
    required this.userName,
    required this.capturedAt,
  });

  factory ScreenshotAlert.fromJson(Map<String, dynamic> json) {
    final userData = json['users'] as Map<String, dynamic>?;
    return ScreenshotAlert(
      id: json['id'] as String,
      messageId: json['message_id'] as String,
      userId: json['user_id'] as String,
      capturedBy: json['captured_by'] as String,
      userName: userData?['display_name'] as String? ?? 'Quelqu\'un',
      capturedAt: DateTime.parse(json['captured_at'] as String),
    );
  }
}
