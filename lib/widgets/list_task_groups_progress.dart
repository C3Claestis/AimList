// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:todolist_app/data/project_model.dart';
import 'package:todolist_app/data/task_status.dart';
import 'package:todolist_app/services/task_group.dart';

class ListTaskGroupsProgress extends StatelessWidget {
  final TaskGroupItem taskGroup;
  final List<ProjectModel> allProjects;

  const ListTaskGroupsProgress({
    super.key,
    required this.taskGroup,
    required this.allProjects,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Filter proyek yang hanya masuk ke dalam grup tugas ini
    final projectsInGroup = allProjects
        .where((project) => project.taskGroup == taskGroup.title)
        .toList();

    // 2. Filter proyek yang sudah selesai dalam grup ini
    final completedProjectsInGroup = projectsInGroup
        .where((project) => project.status == TaskStatus.completed)
        .toList();

    // 3. Hitung jumlah total tugas dan persentase selesai
    final totalTaskCount = projectsInGroup.length;
    final double completionPercentage = totalTaskCount > 0
        ? completedProjectsInGroup.length / totalTaskCount
        : 1.0; // Jika tidak ada tugas, anggap 100% selesai

    return Container(
      width: 331,
      height: 66,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 12),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: taskGroup.color, // Warna dari TaskGroupItem
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(taskGroup.icon, color: Colors.white, size: 20), // Ikon dari TaskGroupItem
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 180, // Disesuaikan agar tidak terlalu lebar
                    child: Text(
                      taskGroup.title, // Judul dari TaskGroupItem
                      style: GoogleFonts.lexendDeca(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '$totalTaskCount Tasks', // Jumlah tugas dari hasil filter
                    style: GoogleFonts.lexendDeca(
                      fontSize: 11,
                      color: const Color(0xFF6E6A7C),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 19),
            child: SizedBox(
              width: 42,
              height: 42,
              child: CircularPercentIndicator(
                startAngle: 90,
                backgroundColor: taskGroup.color.withOpacity(0.25),
                radius: 21,
                lineWidth: 7.0,
                animation: true,
                percent: completionPercentage, // Persentase dari hasil kalkulasi
                center: Text(
                  "${(completionPercentage * 100).toInt()}%",
                  style: GoogleFonts.lexendDeca(
                    fontSize: 10,
                    color: Colors.black,
                  ),
                ),
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: taskGroup.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
