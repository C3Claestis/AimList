// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:todolist_app/data/project_db.dart';
import 'package:todolist_app/data/project_model.dart';
import 'package:todolist_app/data/task_status.dart';
import 'package:todolist_app/services/task_group.dart';
import 'package:todolist_app/services/page_widget.dart';

class ProjectDetailPage extends StatefulWidget {
  final ProjectModel project;
  final dynamic projectKey;

  const ProjectDetailPage({
    super.key,
    required this.project,
    required this.projectKey,
  });

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  late TaskStatus _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.project.status;
  }

  void _updateProjectStatus() async {
    // Buat objek project baru dengan status yang diperbarui
    final updatedProject = ProjectModel(
      taskGroup: widget.project.taskGroup,
      projectName: widget.project.projectName,
      description: widget.project.description,
      startTime: widget.project.startTime,
      endTime: widget.project.endTime,
      startDate: widget.project.startDate,
      endDate: widget.project.endDate,
      status: _selectedStatus,
    );

    // Panggil fungsi update dari ProjectDB
    await ProjectDB.updateProject(widget.projectKey, updatedProject);

    // Tampilkan notifikasi dan kembali
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Status proyek berhasil diperbarui!')),
    );
    Navigator.pop(context, true); // Kirim 'true' untuk menandakan ada perubahan
  }

  /// Fungsi untuk menghapus project
  void _deleteProject() async {
    // Hapus project dari database menggunakan key-nya
    await ProjectDB.deleteProject(widget.projectKey);

    // Tampilkan notifikasi bahwa project berhasil dihapus
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Project berhasil dihapus!'),
        backgroundColor: Colors.green,
      ),
    );

    // Kembali ke halaman sebelumnya dan kirim 'true' untuk refresh data
    Navigator.pop(context, true);
  }

  // Fungsi untuk mendapatkan detail (ikon dan warna) dari task group
  TaskGroupItem _getTaskGroupDetails(String taskGroupTitle) {
    // Cari item yang cocok, jika tidak ada, kembalikan item 'Other'
    return taskGroupItems.firstWhere(
      (item) => item.title == taskGroupTitle,
      orElse: () => taskGroupItems.last, // Default ke 'Other'
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageWidget(
      isSpalashScreen: false,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        children: [
          _header(context),
          const Gap(24),
          _buildTaskGroupField(widget.project.taskGroup),
          const Gap(16),
          _buildDisplayField(
            "Project Name",
            widget.project.projectName,
            null, // Tidak ada ikon
          ),
          const Gap(16),
          _buildDisplayField(
            "Description",
            widget.project.description,
            null, // Tidak ada ikon
          ),
          const Gap(16),
          _timeDisplayField(),
          const Gap(16),
          _dateDisplayField(),
          const Gap(24),
          _statusSelector(),
          const Gap(32),
          _saveButton(),
          const Gap(16),
          _deleteButton(),
        ],
      ),
    );
  }

  Row _dateDisplayField() {
    return Row(
      children: [
        Expanded(
          child: _buildDisplayField(
            "Start Date",
            DateFormat('dd MMM, yyyy').format(widget.project.startDate),
            Icons.calendar_today_rounded,
          ),
        ),
        const Gap(16),
        Expanded(
          child: _buildDisplayField(
            "End Date",
            DateFormat('dd MMM, yyyy').format(widget.project.endDate),
            Icons.calendar_month_rounded,
          ),
        ),
      ],
    );
  }

  Row _timeDisplayField() {
    return Row(
      children: [
        Expanded(
          child: _buildDisplayField(
            "Start Time",
            widget.project.startTime,
            Icons.access_time_rounded,
          ),
        ),
        const Gap(16),
        Expanded(
          child: _buildDisplayField(
            "End Time",
            widget.project.endTime,
            Icons.access_time_filled_rounded,
          ),
        ),
      ],
    );
  }

  /// Header Halaman
  Padding _header(BuildContext context) {
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
              'Project Detail',
              style: GoogleFonts.lexendDeca(
                fontSize: 19,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(48),
          ],
        ),
      ),
    );
  }

  /// Widget untuk menampilkan data (tidak bisa diedit)
  Widget _buildDisplayField(String label, String value, IconData? icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: const Color(0xFF6E6A7C), size: 20),
            const Gap(12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: GoogleFonts.lexendDeca(
                    fontSize: 9,
                    color: const Color(0xFF6E6A7C),
                  ),
                ),
                const Gap(4),
                Text(
                  value,
                  style: GoogleFonts.lexendDeca(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 5, // Batasi deskripsi agar tidak terlalu panjang
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Widget khusus untuk menampilkan Task Group dengan ikon dan warna yang sesuai.
  Widget _buildTaskGroupField(String taskGroupTitle) {
    final taskGroupDetail = _getTaskGroupDetails(taskGroupTitle);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: taskGroupDetail.color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(taskGroupDetail.icon, color: Colors.white, size: 14),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Task Group",
                  style: GoogleFonts.lexendDeca(
                    fontSize: 9,
                    color: const Color(0xFF6E6A7C),
                  ),
                ),
                const Gap(4),
                Text(
                  taskGroupTitle,
                  style: GoogleFonts.lexendDeca(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Widget untuk memilih status
  Widget _statusSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatusRadioButton(TaskStatus.todo, 'To do'),
        _buildStatusRadioButton(TaskStatus.inProgress, 'In Progress'),
        _buildStatusRadioButton(TaskStatus.completed, 'Complete'),
      ],
    );
  }

  /// Widget untuk satu tombol radio status
  Widget _buildStatusRadioButton(TaskStatus status, String label) {
    final bool isSelected = _selectedStatus == status;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedStatus = status;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? const Color(0xFF5F33E1)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF5F33E1)
                      : Colors.grey.shade400,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const Gap(8),
            Text(
              label,
              style: GoogleFonts.lexendDeca(
                fontSize: 12,
                color: isSelected ? const Color(0xFF5F33E1) : Colors.black,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Tombol Simpan
  TextButton _saveButton() {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: _updateProjectStatus,
          splashColor: Colors.white.withOpacity(0.2), // opsional
          highlightColor: Colors.white.withOpacity(0.1), // opsional
          child: Ink(
            width: 331,
            height: 52,
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage("assets/images/Rectangle.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Text(
                'Save Changes',
                style: GoogleFonts.lexendDeca(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  //Button Delete Project
  Widget _deleteButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: OutlinedButton.icon(
        onPressed: () {
          // Tampilkan dialog konfirmasi sebelum menghapus
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Konfirmasi Hapus'),
                content: const Text(
                  'Apakah Anda yakin ingin menghapus proyek ini?',
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Tidak'),
                    onPressed: () {
                      // Tutup dialog
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text(
                      'Yakin',
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                    onPressed: () {
                      // Tutup dialog dan panggil fungsi hapus
                      Navigator.of(context).pop();
                      _deleteProject();
                    },
                  ),
                ],
              );
            },
          );
        },
        icon: const Icon(
          Icons.delete_forever_rounded,
          color: Colors.red,
          size: 24,
        ),
        label: Text(
          'Delete Project',
          style: GoogleFonts.lexendDeca(
            color: Colors.red,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(331, 52),
          side: const BorderSide(color: Colors.red, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
