import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _local = FlutterLocalNotificationsPlugin();
  Future<void> Function()? _onOpenRandom;

  static const _channelId = 'reminders';
  static const _channelName = 'Reminders';

  Future<void> init({required Future<void> Function() onOpenRandom}) async {
    _onOpenRandom = onOpenRandom;

    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _local.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (_) async {
        final cb = _onOpenRandom;
        if (cb != null) await cb();
      },
    );

    final android = _local.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        importance: Importance.high,
      ),
    );
    await android?.requestNotificationsPermission();

    final ios = _local.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);

    await FirebaseMessaging.instance.requestPermission(alert: true, badge: true, sound: true);

    FirebaseMessaging.onMessage.listen((m) async {
      final n = m.notification;
      if (n == null) return;
      await _showNow(title: n.title ?? 'MealLab', body: n.body ?? 'Open the app');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((_) async {
      final cb = _onOpenRandom;
      if (cb != null) await cb();
    });

    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      final cb = _onOpenRandom;
      if (cb != null) await cb();
    }
  }

  Future<void> _showNow({required String title, required String body}) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
    await _local.show(101, title, body, details);
  }

  Future<void> scheduleDailyReminder({required int hour, required int minute}) async {
    final now = tz.TZDateTime.now(tz.local);
    var next = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (next.isBefore(now)) next = next.add(const Duration(days: 1));

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _local.zonedSchedule(
      202,
      'Random recipe',
      'Open MealLab to see today’s random recipe',
      next,
      details,
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );

  }
}
