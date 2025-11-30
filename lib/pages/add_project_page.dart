// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todolist_app/services/page_widget.dart';
import 'package:todolist_app/services/task_group.dart';
import 'package:todolist_app/data/project_db.dart';
import 'package:todolist_app/data/project_model.dart';
import 'package:todolist_app/data/task_status.dart';

/// Enum untuk merepresentasikan status proyek.
enum ProjectStatus { toDo, inProgress, complete }

class AddProjectPage extends StatefulWidget {
  const AddProjectPage({super.key});

  @override
  State<AddProjectPage> createState() => _AddProjectPageState();
}

class _AddProjectPageState extends State<AddProjectPage> {
  /// Menyimpan item yang sedang dipilih di dropdown.
  late TaskGroupItem _selectedTaskGroup;

  // Controller untuk semua field input
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  final _formKey = GlobalKey<FormState>(); // Kunci untuk validasi form

  // State untuk menyimpan status yang dipilih, defaultnya 'To do'.
  ProjectStatus _selectedStatus = ProjectStatus.toDo;

  @override
  void initState() {
    super.initState();
    // Mengatur item terpilih awal ke item pertama dari daftar.
    _selectedTaskGroup = taskGroupItems.first;
  }

  @override
  void dispose() {
    // Membersihkan controller saat widget tidak lagi digunakan
    _projectNameController.dispose();
    _descriptionController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  /// Fungsi untuk menampilkan time picker dan memperbarui field.
  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF5F33E1), // Header background
              onPrimary: Colors.white, // Header text
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        (isStartTime ? _startTimeController : _endTimeController).text = picked
            .format(context);
      });
    }
  }

  /// Fungsi untuk menampilkan date picker dan memperbarui field.
  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF5F33E1), // Header background
              onPrimary: Colors.white, // Header text
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('dd MMM, yyyy').format(picked);
      });
    }
  }

  /// Konversi dari enum status UI ke enum model data
  TaskStatus _getTaskStatus(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.toDo:
        return TaskStatus.todo;
      case ProjectStatus.inProgress:
        return TaskStatus.inProgress;
      case ProjectStatus.complete:
        return TaskStatus.completed;
    }
  }

  /// Fungsi untuk menyimpan project
  void _saveProject() async {
    // Buat objek ProjectModel dari data form
    final newProject = ProjectModel(
      taskGroup: _selectedTaskGroup.title,
      projectName: _projectNameController.text,
      description: _descriptionController.text,
      startTime: _startTimeController.text,
      endTime: _endTimeController.text,
      startDate: DateFormat('dd MMM, yyyy').parse(_startDateController.text),
      endDate: DateFormat('dd MMM, yyyy').parse(_endDateController.text),
      status: _getTaskStatus(_selectedStatus),
    );

    // Panggil fungsi dari ProjectDB untuk menyimpan data
    await ProjectDB.addProject(newProject);

    // Tampilkan notifikasi dan kembali ke halaman sebelumnya
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Project berhasil ditambahkan!')),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return PageWidget(
      isSpalashScreen: false,
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            _header(),
            const Gap(28),
            _buildDropdown(),
            const Gap(24),
            _projectNameInput(),
            const Gap(24),
            _descriptionInput(),
            const Gap(24),
            _timePicker(context),
            const Gap(24),
            _startDateInput(),
            const Gap(24),
            _endDateInput(),
            const Gap(8),
            _statusSelector(),
            const Gap(24),
            _buttonAdd(),
          ],
        ),
      ),
    );
  }

  /// Widget untuk memilih status proyek (To do, In Progress, Complete).
  Widget _statusSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Container(
        width: 331,
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatusRadioButton(ProjectStatus.toDo, 'To do'),
            _buildStatusRadioButton(ProjectStatus.inProgress, 'In Progress'),
            _buildStatusRadioButton(ProjectStatus.complete, 'Complete'),
          ],
        ),
      ),
    );
  }

  /// Widget untuk satu tombol radio status.
  Widget _buildStatusRadioButton(ProjectStatus status, String label) {
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

  /// Widget untuk end tanggal.
  Widget _endDateInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: GestureDetector(
        onTap: () => _selectDate(context, _endDateController),
        child: Container(
          width: 331,
          height: 66,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/svgs/calenderBtn.svg',
                    height: 24,
                    width: 24,
                  ),
                  const Gap(12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "End Date",
                        style: GoogleFonts.lexendDeca(
                          fontSize: 9,
                          color: const Color(0xFF6E6A7C),
                        ),
                      ),
                      Text(
                        _endDateController.text.isEmpty
                            ? 'Select End Date' // Teks petunjuk jika kosong
                            : _endDateController.text, // Tanggal yang dipilih
                        style: _endDateController.text.isEmpty
                            ? GoogleFonts.lexendDeca(
                                fontSize: 12,
                                color: const Color(0xFF6E6A7C),
                                fontStyle: FontStyle.italic,
                              )
                            : GoogleFonts.lexendDeca(
                                fontSize: 14,
                                color: const Color(0xFF1D1617),
                                fontWeight: FontWeight.w600,
                              ),
                      ),
                    ],
                  ),
                ],
              ),
              SvgPicture.asset('assets/svgs/dropdown.svg'),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget untuk start tanggal.
  Widget _startDateInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: GestureDetector(
        onTap: () => _selectDate(context, _startDateController),
        child: Container(
          width: 331,
          height: 66,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/svgs/calenderBtn.svg',
                    height: 24,
                    width: 24,
                  ),
                  const Gap(12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Start Date",
                        style: GoogleFonts.lexendDeca(
                          fontSize: 9,
                          color: const Color(0xFF6E6A7C),
                        ),
                      ),
                      Text(
                        _startDateController.text.isEmpty
                            ? 'Select Date' // Teks petunjuk jika kosong
                            : _startDateController.text, // Tanggal yang dipilih
                        style: _startDateController.text.isEmpty
                            ? GoogleFonts.lexendDeca(
                                fontSize: 12,
                                color: const Color(0xFF6E6A7C),
                                fontStyle: FontStyle.italic,
                              )
                            : GoogleFonts.lexendDeca(
                                fontSize: 14,
                                color: const Color(0xFF1D1617),
                                fontWeight: FontWeight.w600,
                              ),
                      ),
                    ],
                  ),
                ],
              ),
              SvgPicture.asset('assets/svgs/dropdown.svg'),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget untuk input waktu proyek.
  Padding _timePicker(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Container(
        width: 331,
        height: 66,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // START TIME
            Expanded(
              child: GestureDetector(
                onTap: () => _selectTime(context, true),
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE0E0E0),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 18,
                        color: Color(0xFF6E6A7C),
                      ),
                      const Gap(6),
                      Expanded(
                        // Menggunakan Expanded agar Text mengisi ruang yang tersedia
                        child: Text(
                          _startTimeController.text.isEmpty
                              ? 'Start' // Teks petunjuk jika kosong
                              : _startTimeController.text, // Waktu yang dipilih
                          style: _startTimeController.text.isEmpty
                              ? GoogleFonts.lexendDeca(
                                  fontSize: 12,
                                  color: const Color(0xFF6E6A7C),
                                  fontStyle: FontStyle.italic,
                                )
                              : GoogleFonts.lexendDeca(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                          overflow:
                              TextOverflow.ellipsis, // Menangani teks panjang
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Gap(12),

            // END TIME
            Expanded(
              child: GestureDetector(
                onTap: () => _selectTime(context, false),
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE0E0E0),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 18,
                        color: Color(0xFF6E6A7C),
                      ),
                      const Gap(6),
                      Expanded(
                        // Menggunakan Expanded agar Text mengisi ruang yang tersedia
                        child: Text(
                          _endTimeController.text.isEmpty
                              ? 'End' // Teks petunjuk jika kosong
                              : _endTimeController.text, // Waktu yang dipilih
                          style: _endTimeController.text.isEmpty
                              ? GoogleFonts.lexendDeca(
                                  fontSize: 12,
                                  color: const Color(0xFF6E6A7C),
                                  fontStyle: FontStyle.italic,
                                )
                              : GoogleFonts.lexendDeca(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                          overflow:
                              TextOverflow.ellipsis, // Menangani teks panjang
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget untuk input deskripsi proyek.
  Padding _descriptionInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Container(
        width: 331,
        // height dihapus agar Container dapat menyesuaikan tinggi secara otomatis
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Description",
                style: GoogleFonts.lexendDeca(
                  fontSize: 9,
                  color: const Color(0xFF6E6A7C),
                ),
              ),
              const Gap(1),
              SizedBox(
                width: 320,
                // height dihapus agar TextFormField dapat meluas secara vertikal
                child: TextFormField(
                  controller: _descriptionController,
                  style: GoogleFonts.lexendDeca(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  inputFormatters: [LengthLimitingTextInputFormatter(1000)],
                  maxLines: null, // Memungkinkan teks untuk multi-line
                  keyboardType: TextInputType
                      .multiline, // Mengaktifkan keyboard multi-line
                  decoration: InputDecoration(
                    hintText: 'Enter your description',
                    hintStyle: GoogleFonts.lexendDeca(
                      fontSize: 12,
                      color: const Color(0xFF6E6A7C),
                      fontStyle: FontStyle.italic,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget untuk input nama proyek.
  Padding _projectNameInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Container(
        width: 331,
        height: 66,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Project Name",
                style: GoogleFonts.lexendDeca(
                  fontSize: 9,
                  color: const Color(0xFF6E6A7C),
                ),
              ),
              const Gap(1),
              SizedBox(
                width: 320,
                height: 18,
                child: TextFormField(
                  controller: _projectNameController,
                  style: GoogleFonts.lexendDeca(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  inputFormatters: [LengthLimitingTextInputFormatter(38)],
                  decoration: InputDecoration(
                    hintText: 'Enter your project name',
                    hintStyle: GoogleFonts.lexendDeca(
                      fontSize: 12,
                      color: const Color(0xFF6E6A7C),
                      fontStyle: FontStyle.italic,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget untuk membangun dropdown.
  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: PopupMenuButton<TaskGroupItem>(
        onSelected: (TaskGroupItem result) {
          // Memperbarui state ketika item baru dipilih.
          setState(() {
            _selectedTaskGroup = result;
          });
        },
        itemBuilder: (BuildContext context) => taskGroupItems
            .map(
              (item) => PopupMenuItem<TaskGroupItem>(
                value: item,
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: item.color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(item.icon, color: Colors.white, size: 14),
                    ),
                    const Gap(12),
                    Text(item.title),
                  ],
                ),
              ),
            )
            .toList(),
        // Tampilan utama dropdown yang menunjukkan item terpilih.
        child: Container(
          width: 331,
          height: 66,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color:
                          _selectedTaskGroup.color, // Warna dari item terpilih
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _selectedTaskGroup.icon, // Ikon dari item terpilih
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                  const Gap(12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Task Group",
                        style: GoogleFonts.lexendDeca(
                          fontSize: 9,
                          color: const Color(0xFF6E6A7C),
                        ),
                      ),
                      Text(
                        _selectedTaskGroup.title, // Judul dari item terpilih
                        style: GoogleFonts.lexendDeca(
                          fontSize: 14,
                          color: const Color(0xFF1D1617),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SvgPicture.asset('assets/svgs/dropdown.svg'),
            ],
          ),
        ),
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
              'Add Project',
              style: GoogleFonts.lexendDeca(
                fontSize: 19,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(48), // Placeholder untuk presisi
          ],
        ),
      ),
    );
  }

  TextButton _buttonAdd() {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: _saveProject,
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
                'Add Project',
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
}
