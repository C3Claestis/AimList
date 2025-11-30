// ignore_for_file: deprecated_member_use

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notification =
      FlutterLocalNotificationsPlugin();

  // -------------------------------------------------------------
  // INIT NOTIFICATION
  // -------------------------------------------------------------
  static Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidInit);

    await _notification.initialize(initSettings);
  }

  // -------------------------------------------------------------
  // NOTIFIKASI RANGKUMAN HARIAN JAM 00:00
  // -------------------------------------------------------------
  static Future<void> scheduleDailySummary({
    required List<String> todo,
    required List<String> inProgress,
    required List<String> done,
  }) async {
    // Ubah list menjadi string multi-line
    final summary = _buildSummary(todo, inProgress, done);

    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1, 0, 0);

    await _notification.zonedSchedule(
      999, // ID spesial untuk daily summary
      "Daily Summary - AimList",
      summary,
      tz.TZDateTime.from(nextMidnight, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_summary',
          'Daily Summary',
          channelDescription: 'Ringkasan tugas harian',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily 00:00
    );
  }

  // -------------------------------------------------------------
  // BUILDER RINGKASAN
  // -------------------------------------------------------------
  static String _buildSummary(
      List<String> todo, List<String> inProgress, List<String> done) {
    final t = todo.isEmpty ? "- Tidak ada" : todo.map((e) => "• $e").join("\n");
    final p = inProgress.isEmpty
        ? "- Tidak ada"
        : inProgress.map((e) => "• $e").join("\n");
    final d = done.isEmpty ? "- Tidak ada" : done.map((e) => "• $e").join("\n");

    return """
To-Do:
$t

In-Progress:
$p

Selesai:
$d
""";
  }

  // -------------------------------------------------------------
  // OPSIONAL: TEST SEKARANG
  // -------------------------------------------------------------
  static Future<void> debugTestNow() async {
    await _notification.show(
      123,
      "Test Notifikasi AimList",
      "Notifikasi berjalan normal.",
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test',
          channelDescription: 'Untuk testing notifikasi',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}
