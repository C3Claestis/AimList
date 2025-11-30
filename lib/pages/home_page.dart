// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:todolist_app/data/project_db.dart';
import 'package:todolist_app/data/profile_model.dart';
import 'package:todolist_app/data/project_model.dart';
import 'package:todolist_app/data/task_status.dart';
import 'package:todolist_app/pages/about_page.dart';
import 'package:todolist_app/pages/notification_page.dart';
import 'package:todolist_app/services/page_widget.dart';
import 'package:todolist_app/services/task_group.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:todolist_app/widgets/list_in_progress.dart';
import 'package:todolist_app/widgets/list_task_groups_progress.dart';
import 'package:todolist_app/services/notification_controller.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? onViewTaskTap;

  const HomePage({super.key, this.onViewTaskTap});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late Future<List<ProjectModel>> _projectsFuture;
  ProfileModel? _profile;

  @override
  void initState() {
    super.initState();
    // Memuat semua proyek dari database saat widget pertama kali dibuat
    _projectsFuture = ProjectDB.getAllProjects();
    _loadProfile();
  }

  /// Fungsi publik untuk me-refresh data dari luar (misal: dari MainFrame).
  void refreshData() {
    if (mounted) {
      setState(() {
        _projectsFuture = ProjectDB.getAllProjects();
        _loadProfile(); // Muat ulang profil juga jika diperlukan
      });
    }
  }

  // Fungsi untuk mengambil data profil dari Hive
  Future<void> _loadProfile() async {
    final profileBox = await Hive.openBox<ProfileModel>('profileBox');
    // Cek jika widget masih terpasang sebelum memanggil setState
    if (mounted) {
      setState(() {
        // Ambil profil, jika tidak ada, buat profil default
        _profile =
            profileBox.get('userProfile') ??
            ProfileModel(name: 'Guest', email: '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageWidget(
      isSpalashScreen: false,
      child: FutureBuilder<List<ProjectModel>>(
        future: _projectsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Tidak ada proyek.'));
          }

          final allProjects = snapshot.data!;
          final today = DateTime.now();

          // 1. Filter semua proyek yang terjadwal untuk hari ini
          final todayProjects = allProjects
              .where(
                (p) =>
                    p.startDate.year == today.year &&
                    p.startDate.month == today.month &&
                    p.startDate.day == today.day,
              )
              .toList();

          // 2. Hitung persentase tugas hari ini yang selesai
          final completedToday = todayProjects
              .where((p) => p.status == TaskStatus.completed)
              .toList();
          final double todayPercentage = todayProjects.isNotEmpty
              ? completedToday.length / todayProjects.length
              : 1.0; // Jika tidak ada tugas, anggap 100% selesai

          // 3. Filter proyek hari ini yang sedang "In Progress"
          final inProgressProjects = todayProjects
              .where((p) => p.status == TaskStatus.inProgress)
              .toList();

          return ListView(
            children: [
              _header(), // Kirim status notifikasi ke header
              const Gap(24),
              _widgetPercent(todayPercentage), // Gunakan persentase dinamis
              const Gap(24),
              _headerTxt("In Progress", inProgressProjects.length),
              const Gap(16),
              _listInProgress(inProgressProjects, todayProjects),
              const Gap(24),
              _headerTxt("Task Groups", taskGroupItems.length),
              const Gap(16),
              _listTaskGroups(todayProjects), // Kirim data hari ini saja
              const Gap(16),
            ],
          );
        },
      ),
    );
  }

  Widget _listInProgress(
    List<ProjectModel> inProgressProjects,
    List<ProjectModel> todayProjects,
  ) {
    // Jika tidak ada proyek yang sedang dikerjakan, tampilkan widget pemberitahuan.
    if (inProgressProjects.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Container(
          height: 125,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/sticker_yangyang.png',
                  width: 108,
                  height: 108,
                ),
                Text(
                  "No tasks in progress.",
                  style: GoogleFonts.lexendDeca(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 22),
      child: SizedBox(
        height: 116,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: inProgressProjects.length,
          separatorBuilder: (BuildContext context, int index) => const Gap(16),
          itemBuilder: (BuildContext context, int index) {
            final project = inProgressProjects[index];

            // Hitung progres untuk grup tugas dari proyek ini
            final projectsInSameGroup = todayProjects
                .where((p) => p.taskGroup == project.taskGroup)
                .toList();
            final completedInSameGroup = projectsInSameGroup
                .where((p) => p.status == TaskStatus.completed)
                .toList();

            final double groupProgress = projectsInSameGroup.isNotEmpty
                ? completedInSameGroup.length / projectsInSameGroup.length
                : 0.0;

            return ListInProgress(
              project: project,
              progress:
                  groupProgress, // Gunakan progress dinamis dari grup tugasnya
            );
          },
        ),
      ),
    );
  }

  Widget _listTaskGroups(List<ProjectModel> todayProjects) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: taskGroupItems.length, // Iterasi sebanyak jumlah grup tugas
        separatorBuilder: (context, index) => const Gap(16),
        itemBuilder: (context, index) {
          final taskGroup = taskGroupItems[index];
          // Widget ListTaskGroupsProgress sekarang menerima data hari ini saja
          return ListTaskGroupsProgress(
            taskGroup: taskGroup,
            allProjects: todayProjects,
          );
        },
      ),
    );
  }

  Padding _headerTxt(String txt, int value) {
    return Padding(
      padding: const EdgeInsets.only(left: 19),
      child: Row(
        children: [
          Text(
            txt,
            style: GoogleFonts.lexendDeca(
              fontSize: 19,
              fontWeight: FontWeight.w600,
            ),
          ),
          Gap(6),
          Container(
            decoration: BoxDecoration(
              color: Color(0xFFEEE9FF),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            width: 16,
            height: 16,
            child: Text(
              value.toString(),
              style: GoogleFonts.lexendDeca(
                fontSize: 11,
                color: Color(0xFF5F33E1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Padding _widgetPercent(double percent) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: 331,
        height: 146,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Color(0xFF5F33E1),
        ),
        child: Row(
          children: [
            //Teks kiri
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 22, top: 22),
                  child: Text(
                    'Your today’s task \nalmost done!',
                    style: GoogleFonts.lexendDeca(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Gap(14),
                Padding(
                  padding: const EdgeInsets.only(left: 22, bottom: 22),
                  child: TextButton(
                    onPressed: () {
                      widget.onViewTaskTap?.call();
                    },
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: Container(
                      width: 111,
                      height: 38,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9),
                        image: DecorationImage(
                          image: AssetImage("assets/images/btn-2.png"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'View Task',
                        style: GoogleFonts.lexendDeca(
                          color: Color(0xFF5F33E1),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Gap(43),
            Container(
              width: 76,
              height: 76,
              alignment: Alignment.topCenter,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double size = constraints.maxWidth;
                  return CircularPercentIndicator(
                    startAngle: 90,
                    backgroundColor: Color(0xFF8764FF),
                    radius: size / 2,
                    lineWidth: 10.0,
                    animation: true,
                    percent: percent,
                    center: Text(
                      "${(percent * 100).toInt()}%",
                      style: GoogleFonts.lexendDeca(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    circularStrokeCap: CircularStrokeCap.round,
                    progressColor: Colors.white,
                  );
                },
              ),
            ),
            const Gap(43),
            //Button Atas kanan
            Transform.translate(
              offset: Offset(7, -38),
              child: SizedBox(
                width: 24,
                height: 24,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AboutPage(),
                        ),
                      );
                    },
                    child: SvgPicture.asset('assets/svgs/triple_dot.svg'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding _header() {
    return Padding(
      padding: const EdgeInsets.only(top: 28, left: 24, right: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                //Avatar Circle
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color.fromARGB(255, 0, 0, 0),
                      width: 1.5,
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundImage:
                        (_profile?.imagePath != null &&
                            _profile!.imagePath!.isNotEmpty &&
                            File(_profile!.imagePath!).existsSync())
                        ? FileImage(File(_profile!.imagePath!)) as ImageProvider
                        : const AssetImage('assets/images/User.png'),
                    backgroundColor: Colors.grey.shade600,
                  ),
                ),
                const Gap(16),
                //Kolom Name
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello!',
                      style: GoogleFonts.lexendDeca(
                        fontSize: 14,
                        letterSpacing: 0 / 100,
                      ),
                    ),
                    Text(
                      _profile?.name ?? 'Guest',
                      style: GoogleFonts.lexendDeca(
                        fontSize: 19,
                        letterSpacing: 0 / 100,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
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
    );
  }
}
