// File: lib/pages/main_frame.dart

import 'package:flutter/material.dart';
import 'package:todolist_app/pages/add_project_page.dart';
import 'package:todolist_app/pages/document_page.dart';
import 'package:todolist_app/pages/home_page.dart';
import 'package:todolist_app/pages/show_profile_page.dart';
import 'package:todolist_app/pages/today_task_page.dart';
import 'package:todolist_app/widgets/navbar.dart';

class MainFrame extends StatefulWidget {
  const MainFrame({super.key});

  @override
  State<MainFrame> createState() => _MainFrameState();
}

class _MainFrameState extends State<MainFrame> {
  int _currentIndex = 0;

  // Buat GlobalKey untuk setiap state halaman yang perlu di-refresh
  final GlobalKey<HomePageState> _homeKey = GlobalKey<HomePageState>();
  final GlobalKey<TodayTaskState> _todayTaskKey = GlobalKey<TodayTaskState>();
  final GlobalKey<DocumentPageState> _documentKey = GlobalKey<DocumentPageState>();

  void _onNavbarTap(int index) async {
    if (index == 99) {
      final isAdded = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddProjectPage()),
      );

      if (isAdded == true) {
        // Panggil fungsi refresh di halaman yang sedang aktif
        _homeKey.currentState?.refreshData();
        _todayTaskKey.currentState?.refreshData();
        _documentKey.currentState?.refreshData();
        // Tidak perlu setState di MainFrame lagi
      }
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      // Berikan key ke widget halaman
      HomePage(key: _homeKey, onViewTaskTap: () => _onNavbarTap(1)),
      TodayTaskPage(key: _todayTaskKey),
      DocumentPage(key: _documentKey),
      const ShowProfilePage(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      extendBody: true,
      bottomNavigationBar: Navbar(
        currentIndex: _currentIndex,
        onTap: _onNavbarTap,
      ),
    );
  }
}
