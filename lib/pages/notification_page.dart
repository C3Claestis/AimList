// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todolist_app/data/project_db.dart';
import 'package:todolist_app/data/project_model.dart';
import 'package:todolist_app/data/task_status.dart';
import 'package:todolist_app/services/notification_controller.dart';
import 'package:todolist_app/services/page_widget.dart';

/// Enum untuk merepresentasikan jenis notifikasi.
enum NotificationType {
  startingToday,
  deadlineToday,
  overdue,
  inProgress,
  deadlineSoon,
}

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  // Model untuk menampung notifikasi beserta jenisnya.
  final List<Map<String, dynamic>> _notificationItems = [];
  bool _isLoading = true;

  /// 🔥 Index notifikasi (jumlah notif)
  int notificationCount = 0;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final dismissedBox = await Hive.openBox<bool>('dismissedNotifications');
    final allProjectsMap = await ProjectDB.getAllProjectsWithKeys();

    final now = DateTime.now();
    final todayOnly = DateTime(now.year, now.month, now.day);

    final List<Map<String, dynamic>> notifications = [];

    for (var entry in allProjectsMap.entries) {
      final key = entry.key;
      final p = entry.value;

      final start = p.startDate;
      final end = p.endDate;

      final endOnly = DateTime(end.year, end.month, end.day);

      final diffToStart = start.difference(now).inMinutes; // menit menuju start
      final diffToDeadline = end.difference(now).inMinutes; // menit menuju end

      // --------------------------------------------------
      // 1️⃣ OVERDUE
      // --------------------------------------------------
      if (end.isBefore(now) && p.status != TaskStatus.completed) {
        final id = '${key}_overdue';
        if (dismissedBox.get(id) != true) {
          notifications.add({
            'project': p,
            'type': NotificationType.overdue,
            'id': id,
          });
        }
        continue;
      }

      // --------------------------------------------------
      // 2️⃣ TASK MULAI (±1 menit)
      // --------------------------------------------------
      if (diffToStart <= 1 &&
          diffToStart >= -1 &&
          p.status == TaskStatus.todo) {
        final id = '${key}_start';
        if (dismissedBox.get(id) != true) {
          notifications.add({
            'project': p,
            'type': NotificationType.startingToday,
            'id': id,
          });
        }
        continue;
      }

      // --------------------------------------------------
      // 3️⃣ IN PROGRESS
      // --------------------------------------------------
      if (now.isAfter(start) &&
          now.isBefore(end) &&
          p.status == TaskStatus.todo) {
        final id = '${key}_progress';
        if (dismissedBox.get(id) != true) {
          notifications.add({
            'project': p,
            'type': NotificationType.inProgress,
            'id': id,
          });
        }
        continue;
      }

      // --------------------------------------------------
      // 4️⃣ DEADLINE SOON (≤ 30 menit)
      // --------------------------------------------------
      if (diffToDeadline > 0 && diffToDeadline <= 30) {
        final id = '${key}_deadlineSoon';
        if (dismissedBox.get(id) != true) {
          notifications.add({
            'project': p,
            'type': NotificationType.deadlineSoon,
            'id': id,
          });
        }
        continue;
      }

      // --------------------------------------------------
      // 5️⃣ DEADLINE TODAY (tapi >30 menit lagi)
      // --------------------------------------------------
      if (endOnly.isAtSameMomentAs(todayOnly) && diffToDeadline > 30) {
        final id = '${key}_deadlineToday';
        if (dismissedBox.get(id) != true) {
          notifications.add({
            'project': p,
            'type': NotificationType.deadlineToday,
            'id': id,
          });
        }
        continue;
      }
    }

    if (mounted) {
      setState(() {
        _notificationItems
          ..clear()
          ..addAll(notifications);

        notificationCount = notifications.length;
        _isLoading = false;
      });

      // update global notifier agar header & halaman lain tahu
      NotificationController.notificationCount.value = notifications.length;
    }
  }

  /// Menghapus semua notifikasi dari daftar.
  void _clearNotifications() async {
    final dismissedBox = await Hive.openBox<bool>('dismissedNotifications');
    // Simpan semua ID notifikasi yang saat ini ditampilkan ke dalam box 'dismissed'
    for (var item in _notificationItems) {
      await dismissedBox.put(item['id'], true);
    }
    setState(() {
      _notificationItems.clear();
      notificationCount = 0;
    });

    // update global notifier
    NotificationController.notificationCount.value = 0;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Semua notifikasi telah dihapus.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageWidget(
      isSpalashScreen: false,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _header(),
                const Gap(24),
                // Jika tidak ada notifikasi, tampilkan pesan
                if (_notificationItems.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/Rover_sticker.png',
                            width: 128,
                            height: 128,
                          ),
                          Text(
                            "No notifications yet.",
                            style: GoogleFonts.lexendDeca(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  // Jika ada, tampilkan dalam ListView
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      itemCount: _notificationItems.length,
                      separatorBuilder: (context, index) => const Gap(16),
                      itemBuilder: (context, index) {
                        final item = _notificationItems[index];
                        return _buildNotificationCard(
                          item['project'],
                          item['type'],
                        );
                      },
                    ),
                  ),
              ],
            ),
    );
  }

  /// Widget untuk menampilkan satu kartu notifikasi.
  Widget _buildNotificationCard(ProjectModel project, NotificationType type) {
    String title;
    IconData icon;
    Color iconColor;

    switch (type) {
      case NotificationType.startingToday:
        title = "Task Dimulai Hari Ini";
        icon = Icons.flag_circle_rounded;
        iconColor = Colors.green.shade600;
        break;

      case NotificationType.deadlineToday:
        title = "Deadline Hari Ini!";
        icon = Icons.today_rounded; // Ikon berbeda
        iconColor = Colors.red.shade600;
        break;

      case NotificationType.deadlineSoon:
        title = "Deadline Sebentar Lagi!";
        icon = Icons.watch_later_rounded; // Ikon untuk waktu mepet
        iconColor = Colors.orange.shade700;
        break;

      case NotificationType.overdue:
        title = "Tugas Telah Lewat Deadline";
        icon = Icons.event_busy_rounded;
        iconColor = Colors.deepOrangeAccent.shade700;
        break;

      case NotificationType.inProgress:
        title = "Task Sedang Dikerjakan";
        icon = Icons.hourglass_top_rounded;
        iconColor = Colors.amber.shade700;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 28, color: iconColor),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.lexendDeca(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(4),
                Text(
                  project.projectName,
                  style: GoogleFonts.lexendDeca(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Padding _header() {
    return Padding(
      padding: const EdgeInsets.only(top: 28, left: 22, right: 22),
      child: SizedBox(
        width: 331,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Transform.rotate(
                angle: math.pi, // Memutar 180 derajat
                child: SvgPicture.asset(
                  'assets/svgs/button_start.svg',
                  fit: BoxFit.cover,
                  color: Colors.black,
                  width: 24,
                  height: 24,
                ),
              ),
            ),
            Text(
              'Notifications',
              style: GoogleFonts.lexendDeca(
                fontSize: 19,
                fontWeight: FontWeight.w600,
              ),
            ),
            // Tombol untuk menghapus semua notifikasi
            IconButton(
              onPressed: _clearNotifications,
              icon: const Icon(Icons.delete_sweep_rounded, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
