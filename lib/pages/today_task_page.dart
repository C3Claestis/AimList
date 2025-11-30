// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todolist_app/data/task_status.dart';
import 'package:todolist_app/pages/notification_page.dart';
import 'package:todolist_app/services/notification_controller.dart';
import 'package:todolist_app/services/page_widget.dart';
import 'package:intl/intl.dart';
import 'package:todolist_app/data/project_db.dart';
import 'package:todolist_app/data/project_model.dart';
import 'package:todolist_app/widgets/list_today_task.dart';
import 'package:todolist_app/widgets/today_header.dart';

class TodayTaskPage extends StatefulWidget {
  const TodayTaskPage({super.key});

  @override
  State<TodayTaskPage> createState() => TodayTaskState();
}

class TodayTaskState extends State<TodayTaskPage> {
  // State untuk filter header dan future untuk data dari Hive
  int _selectedIndex = 0;
  late Future<Map<dynamic, ProjectModel>> _projectsFuture;

  @override
  void initState() {
    super.initState();
    _projectsFuture = ProjectDB.getAllProjectsWithKeys();
  }

  /// Fungsi publik untuk me-refresh data dari luar (misal: dari MainFrame).
  void refreshData() {
    setState(() {
      _projectsFuture = ProjectDB.getAllProjectsWithKeys();
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dates = List.generate(5, (index) {
      return now.subtract(const Duration(days: 2)).add(Duration(days: index));
    });
    final today = now;

    return PageWidget(
      isSpalashScreen: false,
      child: FutureBuilder<Map<dynamic, ProjectModel>>(
        future: _projectsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          return ListView(
            children: [
              _header(),
              const Gap(32),
              _listDay(dates, today),
              const Gap(32),
              _todayHeader(),
              const Gap(28),
              _buildProjectList(),
            ],
          );
        },
      ),
    );
  }

  /// Widget untuk membangun daftar proyek menggunakan FutureBuilder.
  Widget _buildProjectList() {
    return FutureBuilder<Map<dynamic, ProjectModel>>(
      future: _projectsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 32),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/encore_sticker.png',
                    width: 128,
                    height: 128,
                  ),
                  Text(
                    "You have no tasks yet.",
                    style: GoogleFonts.lexendDeca(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final projectsMap = snapshot.data!;
        final today = DateTime.now();

        // FILTER TANGGAL
        final todayProjectsMap = Map.fromEntries(
          projectsMap.entries.where(
            (entry) =>
                entry.value.startDate.year == today.year &&
                entry.value.startDate.month == today.month &&
                entry.value.startDate.day == today.day,
          ),
        );

        // FILTER STATUS
        Map<dynamic, ProjectModel> filteredMap = todayProjectsMap;
        switch (_selectedIndex) {
          case 0: // 'All'
            break; // Tidak perlu filter tambahan
          case 1:
            filteredMap = Map.fromEntries(
              todayProjectsMap.entries.where(
                (entry) => entry.value.status == TaskStatus.todo,
              ),
            );
            break;
          case 2:
            filteredMap = Map.fromEntries(
              todayProjectsMap.entries.where(
                (entry) => entry.value.status == TaskStatus.inProgress,
              ),
            );
            break;
          case 3:
            filteredMap = Map.fromEntries(
              todayProjectsMap.entries.where(
                (entry) => entry.value.status == TaskStatus.completed,
              ),
            );
            break;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredMap.length,
            separatorBuilder: (context, index) => const Gap(16),
            itemBuilder: (context, index) {
              final key = filteredMap.keys.elementAt(index);
              final project = filteredMap.values.elementAt(index);
              return ListTodayTask(
                project: project,
                projectKey: key,
                onDataUpdated: refreshData,
              );
            },
          ),
        );
      },
    );
  }

  Padding _todayHeader() {
    var headerList = ['All', 'To do', 'In progress', 'Complete'];
    return Padding(
      padding: const EdgeInsets.only(left: 22),
      child: SizedBox(
        height: 34,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 4,
          separatorBuilder: (BuildContext context, int index) => const Gap(12),
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = index;
                });
              },
              child: TodayHeader(
                content: headerList[index].toString(),
                isSelected: _selectedIndex == index,
              ),
            );
          },
        ),
      ),
    );
  }

  SizedBox _listDay(List<DateTime> dates, DateTime today) {
    return SizedBox(
      height: 84,
      child: ListView.separated(
        padding: const EdgeInsets.only(left: 22),
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder: (context, index) => const Gap(12),
        itemBuilder: (context, index) {
          final date = dates[index];
          final isToday =
              date.year == today.year &&
              date.month == today.month &&
              date.day == today.day;
          return _buildDateCard(date, isToday);
        },
      ),
    );
  }

  Widget _buildDateCard(DateTime date, bool isToday) {
    final month = DateFormat.MMM('id_ID').format(date);
    final dayOfMonth = DateFormat.d('id_ID').format(date);
    final dayOfWeek = DateFormat.E('id_ID').format(date);
    final textColor = isToday ? Colors.white : Colors.black;

    return Container(
      width: 64,
      height: 84,
      decoration: BoxDecoration(
        color: isToday ? const Color(0xFF5F33E1) : Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            month,
            style: GoogleFonts.lexendDeca(fontSize: 11, color: textColor),
          ),
          const Gap(8),
          Text(
            dayOfMonth,
            style: GoogleFonts.lexendDeca(
              fontSize: 19,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const Gap(8),
          Text(
            dayOfWeek,
            style: GoogleFonts.lexendDeca(fontSize: 11, color: textColor),
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
            SvgPicture.asset(
              'assets/svgs/button_start.svg',
              fit: BoxFit.cover,
              color: Colors.transparent,
              width: 32,
              height: 32,
            ),
            Text(
              'Today’s Tasks',
              style: GoogleFonts.lexendDeca(
                fontSize: 19,
                fontWeight: FontWeight.w600,
              ),
            ),
            ValueListenableBuilder<int>(
              valueListenable: NotificationController.notificationCount,
              builder: (context, count, child) {
                return Stack(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationPage(),
                          ),
                        );
                      },
                      icon: SvgPicture.asset(
                        'assets/svgs/notif.svg',
                        color: Colors.black,
                        width: 24,
                        height: 24,
                      ),
                    ),
                    if (count > 0) // <-- dot muncul jika count > 0
                      Positioned(
                        right: 15,
                        top: 12,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF5F33E1),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
