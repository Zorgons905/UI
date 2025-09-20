class Notification {
  final int? id;
  final int taskId;
  final String notificationType;
  final DateTime scheduledTime;
  final String title;
  final String body;
  final bool isSent;
  final bool isRead;
  final DateTime createdAt;

  Notification({
    this.id,
    required this.taskId,
    required this.notificationType,
    required this.scheduledTime,
    required this.title,
    required this.body,
    this.isSent = false,
    this.isRead = false,
    required this.createdAt,
  });

  factory Notification.fromMap(Map<String, dynamic> map) {
    return Notification(
      id: map['id'],
      taskId: map['task_id'],
      notificationType: map['notification_type'],
      scheduledTime: DateTime.parse(map['scheduled_time']),
      title: map['title'],
      body: map['body'],
      isSent: map['is_sent'] == 1,
      isRead: map['is_read'] == 1,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'notification_type': notificationType,
      'scheduled_time': scheduledTime.toIso8601String(),
      'title': title,
      'body': body,
      'is_sent': isSent ? 1 : 0,
      'is_read': isRead ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Notification copyWith({
    int? id,
    int? taskId,
    String? notificationType,
    DateTime? scheduledTime,
    String? title,
    String? body,
    bool? isSent,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return Notification(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      notificationType: notificationType ?? this.notificationType,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      title: title ?? this.title,
      body: body ?? this.body,
      isSent: isSent ?? this.isSent,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Notification{id: $id, taskId: $taskId, notificationType: $notificationType, scheduledTime: $scheduledTime, title: $title, body: $body, isSent: $isSent, isRead: $isRead, createdAt: $createdAt}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Notification &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          taskId == other.taskId &&
          notificationType == other.notificationType;

  @override
  int get hashCode => id.hashCode ^ taskId.hashCode ^ notificationType.hashCode;

  static const String threeDays = '3_days';
  static const String oneDay = '1_day';
  static const String sixHours = '6_hours';
  static const String threeHours = '3_hours';

  static List<String> get allNotificationTypes => [
    threeDays,
    oneDay,
    sixHours,
    threeHours,
  ];

  String get readableNotificationType {
    switch (notificationType) {
      case threeDays:
        return '3 Days Before';
      case oneDay:
        return '1 Day Before';
      case sixHours:
        return '6 Hours Before';
      case threeHours:
        return '3 Hours Before';
      default:
        return notificationType;
    }
  }

  bool get shouldSendNow {
    return !isSent && DateTime.now().isAfter(scheduledTime);
  }

  Duration get timeUntilNotification {
    return scheduledTime.difference(DateTime.now());
  }

  bool get isOverdue {
    return !isSent && DateTime.now().isAfter(scheduledTime);
  }
}
