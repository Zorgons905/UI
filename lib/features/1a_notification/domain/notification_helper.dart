import 'dart:io';
import '../data/models/notification.dart';
import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../../../config/db_provider.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static DateTime getIndonesiaTime() {
    try {
      return tz.TZDateTime.now(tz.getLocation('Asia/Jakarta'));
    } catch (e) {
      return DateTime.now().toUtc().add(const Duration(hours: 7));
    }
  }

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/doko_logo');

      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      if (Platform.isAndroid) {
        final androidPlugin =
            _notificationsPlugin
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >();

        if (androidPlugin != null) {
          await androidPlugin.requestNotificationsPermission();
        }
      }

      _initialized = true;
      _startNotificationChecker();
    } catch (e) {
      rethrow;
    }
  }

  static void _onNotificationTapped(NotificationResponse response) async {
    try {
      final notificationId = int.tryParse(response.payload ?? '');
      if (notificationId != null) {
        await markNotificationAsRead(notificationId);
      }
    } catch (e) {
      // Silent error handling
    }
  }

  static Future<void> scheduleNotificationsForTask(
    int taskId,
    String taskName,
    DateTime taskDateTime,
  ) async {
    try {
      final now = getIndonesiaTime();

      if (taskDateTime.isBefore(now)) {
        return;
      }

      final notifications = <Notification>[];

      final threeDaysBefore = taskDateTime.subtract(const Duration(days: 3));
      if (threeDaysBefore.isAfter(now)) {
        notifications.add(
          Notification(
            taskId: taskId,
            notificationType: Notification.threeDays,
            scheduledTime: threeDaysBefore,
            title: 'Task Reminder - 3 Days Left!',
            body:
                'Your task "$taskName" is due in 3 days. Time to start preparing!',
            createdAt: now,
          ),
        );
      }

      final oneDayBefore = taskDateTime.subtract(const Duration(days: 1));
      if (oneDayBefore.isAfter(now)) {
        notifications.add(
          Notification(
            taskId: taskId,
            notificationType: Notification.oneDay,
            scheduledTime: oneDayBefore,
            title: 'Task Reminder - 1 Day Left!',
            body:
                'Your task "$taskName" is due tomorrow. Don\'t forget to complete it!',
            createdAt: now,
          ),
        );
      }

      final sixHoursBefore = taskDateTime.subtract(const Duration(hours: 6));
      if (sixHoursBefore.isAfter(now)) {
        notifications.add(
          Notification(
            taskId: taskId,
            notificationType: Notification.sixHours,
            scheduledTime: sixHoursBefore,
            title: 'Task Reminder - 6 Hours Left!',
            body:
                'Your task "$taskName" is due in 6 hours. Better get started!',
            createdAt: now,
          ),
        );
      }

      final threeHoursBefore = taskDateTime.subtract(const Duration(hours: 3));
      if (threeHoursBefore.isAfter(now)) {
        notifications.add(
          Notification(
            taskId: taskId,
            notificationType: Notification.threeHours,
            scheduledTime: threeHoursBefore,
            title: 'Task Reminder - 3 Hours Left!',
            body:
                'Your task "$taskName" is due in 3 hours. Time is running out!',
            createdAt: now,
          ),
        );
      }

      for (final notification in notifications) {
        await _saveNotificationToDatabase(notification);
      }
    } catch (e) {
      // Silent error handling
    }
  }

  static Future<int> _saveNotificationToDatabase(
    Notification notification,
  ) async {
    try {
      final db = await DBProvider.database;
      return await db.insert('notification', notification.toMap());
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> cancelNotificationsForTask(int taskId) async {
    try {
      final db = await DBProvider.database;

      final notifications = await db.query(
        'notification',
        where: 'task_id = ? AND is_sent = 0',
        whereArgs: [taskId],
      );

      for (final notificationMap in notifications) {
        final notification = Notification.fromMap(notificationMap);
        if (notification.id != null) {
          await _notificationsPlugin.cancel(notification.id!);
        }
      }

      await db.delete(
        'notification',
        where: 'task_id = ? AND is_sent = 0',
        whereArgs: [taskId],
      );
    } catch (e) {
      // Silent error handling
    }
  }

  static Future<List<Notification>> getAllNotifications() async {
    try {
      final db = await DBProvider.database;
      final maps = await db.query(
        'notification',
        orderBy: 'scheduled_time DESC',
      );
      return maps.map((map) => Notification.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<Notification>> getUnreadNotifications() async {
    try {
      final db = await DBProvider.database;
      final maps = await db.query(
        'notification',
        where: 'is_read = 0',
        orderBy: 'scheduled_time DESC',
      );
      return maps.map((map) => Notification.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> markNotificationAsRead(int notificationId) async {
    try {
      final db = await DBProvider.database;
      await db.update(
        'notification',
        {'is_read': 1},
        where: 'id = ?',
        whereArgs: [notificationId],
      );
    } catch (e) {
      // Silent error handling
    }
  }

  static Future<void> markNotificationAsSent(int notificationId) async {
    try {
      final db = await DBProvider.database;
      await db.update(
        'notification',
        {'is_sent': 1},
        where: 'id = ?',
        whereArgs: [notificationId],
      );
    } catch (e) {
      // Silent error handling
    }
  }

  static Future<void> showNotification(Notification notification) async {
    try {
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
            'task_reminders',
            'Task Reminders',
            channelDescription: 'Notifications for upcoming task deadlines',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
            enableVibration: true,
            enableLights: true,
            color: Colors.blue,
          );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
      );

      await _notificationsPlugin.show(
        notification.id!,
        notification.title,
        notification.body,
        notificationDetails,
        payload: notification.id.toString(),
      );

      await markNotificationAsSent(notification.id!);
    } catch (e) {
      // Silent error handling
    }
  }

  static Future<void> checkAndSendDueNotifications() async {
    try {
      final db = await DBProvider.database;
      final now = getIndonesiaTime();

      final checkTime = now.add(const Duration(seconds: 10));

      final maps = await db.query(
        'notification',
        where: 'is_sent = 0 AND scheduled_time <= ?',
        whereArgs: [checkTime.toIso8601String()],
      );

      for (final map in maps) {
        final notification = Notification.fromMap(map);
        final scheduledTime = notification.scheduledTime;

        final tolerance = const Duration(seconds: 30);
        final shouldSend = scheduledTime.isBefore(now.add(tolerance));

        if (shouldSend) {
          await showNotification(notification);
        }
      }
    } catch (e) {
      // Silent error handling
    }
  }

  static void _startNotificationChecker() {
    Stream.periodic(const Duration(seconds: 30)).listen((_) {
      checkAndSendDueNotifications();
    });
  }

  static Future<void> deleteNotification(int notificationId) async {
    try {
      final db = await DBProvider.database;

      await _notificationsPlugin.cancel(notificationId);

      await db.delete(
        'notification',
        where: 'id = ?',
        whereArgs: [notificationId],
      );
    } catch (e) {
      // Silent error handling
    }
  }
}
