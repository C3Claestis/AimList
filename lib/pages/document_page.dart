// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:todolist_app/data/project_db.dart';
import 'package:todolist_app/data/project_model.dart';
import 'package:todolist_app/data/task_status.dart';
import 'package:todolist_app/pages/project_detail_page.dart';
import 'package:todolist_app/services/page_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:todolist_app/services/task_group.dart';

class DocumentPage extends StatefulWidget {
  const DocumentPage({super.key});

  @override
  State<DocumentPage> createState() => DocumentPageState();
}

class DocumentPageState extends State<DocumentPage> {
  Map<DateTime, List<ProjectModel>> _events = {};
  Map<ProjectModel, dynamic> _projectKeys = {};
  late final ValueNotifier<List<ProjectModel>> _selectedEvents;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    _loadProjects();
  }

  /// Fungsi publik untuk me-refresh data dari luar (misal: dari MainFrame).
  void refreshData() {
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    final projectData = await ProjectDB.getAllProjectsWithKeys();
    final Map<DateTime, List<ProjectModel>> newEvents = {};
    final Map<ProjectModel, dynamic> newProjectKeys = {};

    projectData.forEach((key, project) {
      final date = DateTime.utc(
        project.startDate.year,
        project.startDate.month,
        project.startDate.day,
      );
      if (newEvents[date] == null) {
        newEvents[date] = [];
      }
      newEvents[date]!.add(project);
      newProjectKeys[project] = key;
    });

    if (mounted) {
      setState(() {
        _events = newEvents;
        _projectKeys = newProjectKeys;
      });
      _selectedEvents.value = _getEventsForDay(_selectedDay!);
    }
  }

  List<ProjectModel> _getEventsForDay(DateTime day) {
    final date = DateTime.utc(day.year, day.month, day.day);
    return _events[date] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _selectedEvents.value = _getEventsForDay(selectedDay);
      });
    }
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageWidget(
      isSpalashScreen: false,
      child: Column(
        children: [
          _header(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildCalendar(),
          ),
          const Gap(16),
          Expanded(
            child: ValueListenableBuilder<List<ProjectModel>>(
              valueListenable: _selectedEvents,
              builder: (context, value, _) {
                if (value.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/Chixia_sticker.png',
                          width: 128,
                          height: 128,
                        ),
                        Text(
                          'No tasks for this day.',
                          style: GoogleFonts.lexendDeca(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: value.length,
                  separatorBuilder: (_, __) => const Gap(12),
                  itemBuilder: (context, index) {
                    final project = value[index];
                    return _buildEventItem(project);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar<ProjectModel>(
      firstDay: DateTime.utc(2025, 1, 1), // Anda bisa ubah tahun awal di sini
      lastDay: DateTime.utc(2100, 12, 31), // dan tahun akhir di sini
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: _onDaySelected,
      eventLoader: _getEventsForDay,
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: const Color(0xFF5F33E1).withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        selectedDecoration: const BoxDecoration(
          color: Color(0xFF5F33E1),
          shape: BoxShape.circle,
        ),
        markerDecoration: const BoxDecoration(
          color: Color(0xFF8764FF),
          shape: BoxShape.circle,
        ),
      ),
      headerStyle: HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
        titleTextStyle: GoogleFonts.lexendDeca(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  // Helper untuk mendapatkan detail grup tugas
  TaskGroupItem _getTaskGroupDetails(String taskGroupTitle) {
    return taskGroupItems.firstWhere(
      (item) => item.title == taskGroupTitle,
      orElse: () => taskGroupItems.last, // Default ke 'Other'
    );
  }

  // Helper untuk mendapatkan teks status
  String _getStatusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return 'To Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Complete';
    }
  }

  Widget _buildEventItem(ProjectModel project) {
    final taskGroupDetail = _getTaskGroupDetails(project.taskGroup);
    final projectKey = _projectKeys[project];

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        splashColor: const Color(0xFF5F33E1).withOpacity(0.1),
        highlightColor: const Color(0xFF5F33E1).withOpacity(0.05),
        onTap: () async {
          if (projectKey == null) return;

          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ProjectDetailPage(project: project, projectKey: projectKey),
            ),
          );
          if (result == true) {
            _loadProjects(); // Muat ulang data jika ada perubahan
          }
        },
        child: SizedBox(
          width: 331,
          height: 98,
          child: Padding(
            padding: const EdgeInsets.only(
              left: 16,
              bottom: 16,
              top: 12,
              right: 12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      project.taskGroup,
                      style: GoogleFonts.lexendDeca(
                        fontSize: 11,
                        color: const Color(0xFF6E6A7C),
                      ),
                    ),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: taskGroupDetail.color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        taskGroupDetail.icon,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ],
                ),
                const Gap(2),
                Padding(
                  padding: const EdgeInsets.only(right: 24),
                  child: Text(
                    project.projectName,
                    style: GoogleFonts.lexendDeca(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Gap(8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset('assets/svgs/clock.svg'),
                        const Gap(6),
                        Text(
                          project.startTime,
                          style: GoogleFonts.lexendDeca(
                            fontSize: 11,
                            color: const Color(0xFFAB94FF),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 14,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStatusText(project.status),
                        style: GoogleFonts.lexendDeca(
                          fontSize: 9,
                          color: Colors.purple,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Padding _header() {
    return Padding(
      padding: const EdgeInsets.only(top: 28, left: 22, right: 22, bottom: 16),
      child: Text(
        'Document Project',
        style: GoogleFonts.lexendDeca(
          fontSize: 19,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
