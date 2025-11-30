import 'package:flutter/material.dart';

/// Model untuk merepresentasikan setiap item dalam grup tugas.
class TaskGroupItem {
  final String title;
  final IconData icon;
  final Color color;

  TaskGroupItem({required this.title, required this.icon, required this.color});
}

/// Data mentah untuk kategori grup tugas.
final List<Map<String, dynamic>> getTaskGroupModel = [
  {
    'title': 'Work/Office',
    'icon': Icons.work_outline,
    'color': Colors.blue.shade700
  },
  {'title': 'Personal', 'icon': Icons.person_outline, 'color': Colors.green.shade600},
  {'title': 'Event', 'icon': Icons.event, 'color': Colors.lime.shade700},
  {
    'title': 'Family',
    'icon': Icons.family_restroom_outlined,
    'color': Colors.purple.shade500
  },
  {
    'title': 'Study/School/University',
    'icon': Icons.school_outlined,
    'color': Colors.orange.shade800
  },
  {
    'title': 'Health',
    'icon': Icons.favorite_border,
    'color': Colors.red.shade600
  },
  {
    'title': 'Travel',
    'icon': Icons.explore_outlined,
    'color': Colors.teal.shade500
  },
  {
    'title': 'Shopping',
    'icon': Icons.shopping_bag_outlined,
    'color': Colors.pink.shade400
  },
  {
    'title': 'Finance/Bills',
    'icon': Icons.monetization_on_outlined,
    'color': Colors.lightGreen.shade700
  },
  {
    'title': 'Projects',
    'icon': Icons.assignment_outlined,
    'color': Colors.brown.shade500
  },
  {
    'title': 'Self-Care & Mental Health',
    'icon': Icons.spa_outlined,
    'color': Colors.cyan.shade600
  },
  {
    'title': 'Home/Household',
    'icon': Icons.home_outlined,
    'color': Colors.amber.shade800
  },
  {'title': 'Social', 'icon': Icons.group_outlined, 'color': Colors.indigo.shade500},
  {
    'title': 'Media/Entertainment',
    'icon': Icons.live_tv,
    'color': Colors.deepPurple.shade400
  },
  {'title': 'Workouts/Sports', 'icon': Icons.fitness_center, 'color': Colors.deepOrange.shade500},
  {'title': 'Ideas/Notes', 'icon': Icons.lightbulb_outline, 'color': Colors.yellow.shade800},
  {'title': 'Coding/Dev Tasks', 'icon': Icons.code, 'color': Colors.blueGrey.shade600},
  {'title': 'Other', 'icon': Icons.more_horiz_outlined, 'color': Colors.grey.shade700},
];

/// Daftar objek [TaskGroupItem] yang sudah diproses dan siap digunakan oleh UI.
final List<TaskGroupItem> taskGroupItems = getTaskGroupModel.map((item) {
  return TaskGroupItem(
    title: item['title'] as String,
    icon: item['icon'] as IconData,
    color: item['color'] as Color,
  );
}).toList();
