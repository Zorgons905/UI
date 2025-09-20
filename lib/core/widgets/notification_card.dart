import 'package:dokie/features/1a_notification/data/models/notification.dart';
import 'package:dokie/features/1a_notification/domain/notification_helper.dart';
import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_lucide/flutter_lucide.dart';

class NotificationCardList extends StatelessWidget {
  final List<Notification> notifications;
  final VoidCallback? onRefresh;

  const NotificationCardList({
    super.key,
    required this.notifications,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (onRefresh != null) {
          onRefresh!();
        }
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return NotificationCard(
            notification: notification,
            onRefresh: onRefresh,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.bell_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Notifications will appear here when your\ntasks approach their deadlines',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final Notification notification;
  final VoidCallback? onRefresh;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onRefresh,
  });

  Color _getNotificationTypeColor() {
    switch (notification.notificationType) {
      case Notification.threeDays:
        return const Color(0xFF2196F3);
      case Notification.oneDay:
        return const Color(0xFF2196F3);
      case Notification.sixHours:
        return const Color(0xFFFF1744);
      case Notification.threeHours:
        return const Color(0xFFFF1744);
      default:
        return const Color(0xFF2196F3);
    }
  }

  IconData _getNotificationTypeIcon() {
    switch (notification.notificationType) {
      case Notification.threeDays:
      case Notification.oneDay:
        return LucideIcons.clock;
      case Notification.sixHours:
      case Notification.threeHours:
        return LucideIcons.triangle_alert;
      default:
        return LucideIcons.bell;
    }
  }

  String _getNotificationTitle() {
    switch (notification.notificationType) {
      case Notification.threeDays:
      case Notification.oneDay:
        return 'Reminder for ${_extractTaskName()}';
      case Notification.sixHours:
      case Notification.threeHours:
        return 'Deadline for ${_extractTaskName()}';
      default:
        return notification.title;
    }
  }

  String _extractTaskName() {
    final regex = RegExp(r'"([^"]*)"');
    final match = regex.firstMatch(notification.body);
    return match?.group(1) ?? 'Task';
  }

  String _getNotificationDescription() {
    final taskName = _extractTaskName();

    switch (notification.notificationType) {
      case Notification.threeDays:
        return '$taskName\nTask due in 3 days';
      case Notification.oneDay:
        return '$taskName\nTask due tomorrow';
      case Notification.sixHours:
        return '$taskName\nTask due in 6 hours';
      case Notification.threeHours:
        return '$taskName\nTask due in 3 hours';
      default:
        return notification.body;
    }
  }

  Future<void> _markAsRead(BuildContext context) async {
    try {
      if (notification.id != null && !notification.isRead) {
        await NotificationHelper.markNotificationAsRead(notification.id!);
        if (onRefresh != null) {
          onRefresh!();
        }
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getNotificationTypeColor();
    final typeIcon = _getNotificationTypeIcon();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            if (!notification.isRead) {
              _markAsRead(context);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title dengan warna sesuai type
                      Text(
                        _getNotificationTitle(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: typeColor,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Description dengan task name dan timing
                      Text(
                        _getNotificationDescription(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.3,
                        ),
                      ),
                      // Time info untuk context
                      const SizedBox(height: 6),
                      // Unread indicator
                      if (!notification.isRead) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: typeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'New',
                            style: TextStyle(
                              fontSize: 10,
                              color: typeColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Icon di kanan
                Icon(typeIcon, color: typeColor, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
