import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart'; // For Color
import 'package:flutter/services.dart'; // For PlatformException
import 'package:tugas_3/model/task_model.dart'; // Ensure this path is correct
import "package:flutter_timezone/flutter_timezone.dart";

class NotificationService {
  static const String _channelKey = 'task_reminders_channel';

  static Future<void> initializeNotification() async {
    // Initialize Awesome Notifications
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelGroupKey: 'basic_channel_group',
          channelKey: _channelKey,
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic tests',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          playSound: true,
          criticalAlerts: true,
        ),
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'basic_channel_group',
          channelGroupName: 'Basic notifications group',
        ),
      ],
      debug: true,
    );

    // Request notification permissions
    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    // Set notification listeners
    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: _onActionReceivedMethod,
      onNotificationCreatedMethod: _onNotificationCreateMethod,
      onNotificationDisplayedMethod: _onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: _onDismissActionReceivedMethod,
    );
  }

  // Listeners

  static Future<void> _onNotificationCreateMethod(
    ReceivedNotification receivedNotification,
  ) async {
    // debugPrint('Notification created: ${receivedNotification.title}');
  }

  static Future<void> _onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    // debugPrint('Notification displayed: ${receivedNotification.title}');
  }

  static Future<void> _onDismissActionReceivedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    // debugPrint('Notification dismissed: ${receivedNotification.title}');
  }

  static Future<void> _onActionReceivedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    // debugPrint('Notification action received: ${receivedNotification.title}');
  }

  static Future<bool> _checkAndRequestPermission() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      isAllowed = await AwesomeNotifications()
          .requestPermissionToSendNotifications(
            channelKey: _channelKey,
            permissions: [
              NotificationPermission.Alert,
              NotificationPermission.Sound,
              NotificationPermission.Badge,
            ],
          );
    }
    return isAllowed;
  }

  static Future<void> scheduleTaskReminder(Task task) async {
    if (task.id == null) return;

    if (!await _checkAndRequestPermission()) {
      // print(
      //   "Notification permission denied. Cannot schedule reminder for '${task.name}'.",
      // );
      throw PlatformException(
        code: 'INSUFFICIENT_PERMISSIONS',
        message:
            'Notifications are disabled. Please enable them in app settings to receive reminders.',
      );
    }

    DateTime reminderTime = task.deadline.subtract(const Duration(minutes: 15));
    if (reminderTime.isBefore(DateTime.now())) {
      // print(
      //   "Reminder time for task '${task.name}' is in the past. Not scheduling reminder.",
      // );
      return;
    }

    final String localTimeZone = await FlutterTimezone.getLocalTimezone();

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: _getNotificationId(task.id!, 'reminder'),
        channelKey: _channelKey,
        title: 'Task Reminder: ${task.name}',
        body: 'Your task "${task.name}" is due in 15 minutes!',
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar(
        // Updated: Direct instantiation
        year: reminderTime.year,
        month: reminderTime.month,
        day: reminderTime.day,
        hour: reminderTime.hour,
        minute: reminderTime.minute,
        second: 0, // reminderTime.second if needed
        millisecond: 0, // reminderTime.millisecond if needed
        timeZone: localTimeZone,
        preciseAlarm: true,
        // repeats: false, // Default is false
      ),
    );
    // print(
    //   "Scheduled reminder for task '${task.name}' at $reminderTime ($localTimeZone)",
    // );
  }

  static Future<void> scheduleDeadlinePassedNotification(Task task) async {
    if (task.id == null) return;

    // Permission check can be here too if this method might be called independently
    // For now, assuming scheduleTaskReminder would have been called and handled permission.
    // if (!await _checkAndRequestPermission()) { ... throw ... }

    DateTime deadlineTime = task.deadline;
    if (deadlineTime.isBefore(DateTime.now())) {
      // print(
      //   "Deadline for task '${task.name}' is in the past. Not scheduling deadline notification.",
      // );
      return;
    }

    final String localTimeZone = await FlutterTimezone.getLocalTimezone();

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: _getNotificationId(task.id!, 'deadline'),
        channelKey: _channelKey,
        title: 'Task Deadline Passed: ${task.name}',
        body: 'The deadline for your task "${task.name}" has passed.',
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar(
        // Updated: Direct instantiation
        year: deadlineTime.year,
        month: deadlineTime.month,
        day: deadlineTime.day,
        hour: deadlineTime.hour,
        minute: deadlineTime.minute,
        second: 0, // deadlineTime.second if needed
        millisecond: 0, // deadlineTime.millisecond if needed
        timeZone: localTimeZone,
        preciseAlarm: true,
        // repeats: false, // Default is false
      ),
    );
    // print(
    //   "Scheduled deadline notification for task '${task.name}' at $deadlineTime ($localTimeZone)",
    // );
  }

  // Helper to trigger notification immediately if deadline already passed (e.g., on app open)
  // This is optional and depends on how you want to handle already overdue tasks.
  static Future<void> triggerInstantDeadlinePassedNotification(
    Task task,
  ) async {
    if (task.id == null) return;

    // No need for timezone here as it's an immediate notification
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: _getNotificationId(task.id!, 'deadline_instant'),
        channelKey: _channelKey,
        title: 'Task Overdue: ${task.name}',
        body: 'The deadline for your task "${task.name}" has passed.',
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  static Future<void> triggerTaskCreatedNotification(Task task) async {
    if (task.id == null) return; // Should have an ID after creation
    // Permission check might be good here too, or assume it's handled by the scheduling part
    // if (!await _checkAndRequestPermission()) return;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: _getNotificationId(task.id!, 'created'), // Unique ID for this type
        channelKey: _channelKey,
        title: 'Task Created 🎉',
        body: 'New task "${task.name}" has been successfully added.',
        notificationLayout: NotificationLayout.Default,
      ),
      // No schedule parameter means it's an immediate notification
    );
    // print("Triggered notification for task created: ${task.name}");
  }

  static Future<void> triggerTaskUpdatedNotification(Task task) async {
    if (task.id == null) return;
    // if (!await _checkAndRequestPermission()) return;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: _getNotificationId(task.id!, 'updated'), // Unique ID for this type
        channelKey: _channelKey,
        title: 'Task Updated ✏️',
        body: 'Task "${task.name}" has been successfully updated.',
        notificationLayout: NotificationLayout.Default,
      ),
    );
    // print("Triggered notification for task updated: ${task.name}");
  }

  // For delete, might only have the task ID and name if the object is already removed
  static Future<void> triggerTaskDeletedNotification(
    String taskId,
    String taskName,
  ) async {
    // if (!await _checkAndRequestPermission()) return;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: _getNotificationId(taskId, 'deleted'), // Unique ID for this type
        channelKey: _channelKey,
        title: 'Task Deleted 🗑️',
        body: 'Task "$taskName" has been removed.',
        notificationLayout: NotificationLayout.Default,
      ),
    );
    // print("Triggered notification for task deleted: $taskName (ID: $taskId)");
  }

  static Future<void> cancelTaskNotifications(String taskId) async {
    await AwesomeNotifications().cancel(_getNotificationId(taskId, 'reminder'));
    await AwesomeNotifications().cancel(_getNotificationId(taskId, 'deadline'));
    await AwesomeNotifications().cancel(
      _getNotificationId(taskId, 'deadline_instant'),
    );
    // print("Cancelled notifications for task ID: $taskId");
  }

  static int _getNotificationId(String taskId, String type) {
    final String combinedId = '${taskId}_$type';
    return combinedId.hashCode % 2147483647;
  }
}
