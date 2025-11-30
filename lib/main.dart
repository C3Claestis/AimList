import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:todolist_app/data/profile_model.dart';
import 'package:todolist_app/data/project_model.dart';
import 'package:todolist_app/data/task_status.dart';
import 'package:todolist_app/pages/splash_page.dart';
import 'package:todolist_app/services/notification_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// -------------------------------------------------------------
// TIMEZONE SETUP
// -------------------------------------------------------------
Future<void> setupTimeZone() async {
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation("Asia/Jakarta")); // Set timezone lokal
}

// -------------------------------------------------------------
// MAIN
// -------------------------------------------------------------
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Notifikasi
  await NotificationService.init();
  await setupTimeZone();

  // Lokal tanggal Indonesia
  await initializeDateFormatting('id_ID', null);

  // Hive Setup
  await Hive.initFlutter();
  Hive.registerAdapter(ProjectModelAdapter());
  Hive.registerAdapter(TaskStatusAdapter());
  Hive.registerAdapter(ProfileModelAdapter());

  await Hive.openBox<ProfileModel>('profileBox');
  await Hive.openBox<ProjectModel>('project_db');

  // ---------------------------------------------------------
  // ANDROID 13+ PERMISSION (TIDAK DIHAPUS)
  // ---------------------------------------------------------
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  final androidPlugin = flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  // Ada di Android 13+ saja (AMAN tidak error)
  await androidPlugin?.requestNotificationsPermission();

  runApp(const MainApp());
}

// -------------------------------------------------------------
// APP ROOT
// -------------------------------------------------------------
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashPage(),
    );
  }
}
