// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todolist_app/data/project_model.dart';
import 'package:todolist_app/services/task_group.dart';

class ListInProgress extends StatelessWidget {
  final ProjectModel project;
  final double progress; // Tambahkan parameter progress

  const ListInProgress(
      {super.key, required this.project, required this.progress});

  // Fungsi untuk mendapatkan detail (ikon dan warna) dari task group
  TaskGroupItem _getTaskGroupDetails(String taskGroupTitle) {
    return taskGroupItems.firstWhere(
      (item) => item.title == taskGroupTitle,
      orElse: () => taskGroupItems.last, // Default ke 'Other'
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskGroupDetail = _getTaskGroupDetails(project.taskGroup);

    return Container(
      width: 202,
      height: 116,
      decoration: BoxDecoration(
        color: taskGroupDetail.color.withOpacity(0.25),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 12,
          left: 16,
          right: 12,
          bottom: 12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    project.taskGroup, // Mengambil dari task group
                    style: GoogleFonts.lexendDeca(
                      fontSize: 11,
                      color: Color(0xFF6E6A7C),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: taskGroupDetail.color, // Warna dari task group
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(taskGroupDetail.icon, color: Colors.white, size: 14), // Ikon dari task group
                ),
              ],
            ),
            const Gap(6),
            Text(
              project.projectName, // Mengambil dari nama proyek
              style: GoogleFonts.lexendDeca(fontSize: 14, fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Gap(16),
            Container(
              height: 6,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress, // Gunakan progress dinamis dari parameter
                child: Container(
                  decoration: BoxDecoration(
                    color: taskGroupDetail.color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
