// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todolist_app/data/project_model.dart';
import 'package:todolist_app/data/task_status.dart';
import 'package:todolist_app/pages/project_detail_page.dart';
import 'package:todolist_app/services/task_group.dart';

class ListTodayTask extends StatelessWidget {
  final ProjectModel project;
  final dynamic projectKey;
  final VoidCallback onDataUpdated;

  const ListTodayTask({super.key,
    required this.project,
    required this.projectKey,
    required this.onDataUpdated,
  });

  // Fungsi untuk mendapatkan detail (ikon dan warna) dari task group
  TaskGroupItem _getTaskGroupDetails(String taskGroupTitle) {
    // Cari item yang cocok, jika tidak ada, kembalikan item 'Other'
    return taskGroupItems.firstWhere(
      (item) => item.title == taskGroupTitle,
      orElse: () => taskGroupItems.last, // Default ke 'Other'
    );
  }

  // Fungsi untuk mengubah enum status menjadi string yang mudah dibaca
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

  @override
  Widget build(BuildContext context) {
    final taskGroupDetail = _getTaskGroupDetails(project.taskGroup);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        splashColor: const Color(0xFF5F33E1).withOpacity(0.1),
        highlightColor: const Color(0xFF5F33E1).withOpacity(0.05),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ProjectDetailPage(project: project, projectKey: projectKey),
            ),
          );
          if (result == true) {
            onDataUpdated();
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
                // Top row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      project.taskGroup,
                      style: GoogleFonts.lexendDeca(
                        fontSize: 11,
                        color: Color(0xFF6E6A7C),
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

                // Title
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

                // Bottom row
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
                            color: Color(0xFFAB94FF),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 14,
                      padding: EdgeInsets.symmetric(horizontal: 12),
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
}
