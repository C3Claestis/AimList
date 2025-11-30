// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:todolist_app/data/profile_model.dart';
import 'package:todolist_app/pages/edit_profile_page.dart';
import 'package:todolist_app/services/page_widget.dart';

class ShowProfilePage extends StatefulWidget {
  const ShowProfilePage({super.key});

  @override
  State<ShowProfilePage> createState() => _ShowProfilePageState();
}

class _ShowProfilePageState extends State<ShowProfilePage> {
  // Nama Box Hive
  final String profileBoxName = 'profileBox';

  // Data profil
  ProfileModel? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // Fungsi untuk mengambil data profil dari Hive
  Future<void> _loadProfile() async {
    final profileBox = await Hive.openBox<ProfileModel>(profileBoxName);
    setState(() {
      _profile = profileBox.get('userProfile');
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageWidget(
      isSpalashScreen: false,
      child: Center(
        child: Column(
          children: [
            _header(),
            const Gap(24),
            // Avatar
            CircleAvatar(
              radius: 54,
              backgroundImage: (_profile?.imagePath != null &&
                      _profile!.imagePath!.isNotEmpty &&
                      File(_profile!.imagePath!).existsSync())
                  ? FileImage(File(_profile!.imagePath!))
                      as ImageProvider
                  : const AssetImage('assets/images/User.png'),
              backgroundColor: const Color.fromARGB(255, 105, 105, 105),
            ),
            const Gap(32),
            // Menampilkan nama (statis)
            _buildDisplayField("Name", _profile?.name ?? 'Enter your name'),
            const Gap(24),
            // Menampilkan email (statis)
            _buildDisplayField(
              "Email",
              _profile?.email ?? 'Enter your email address',
            ),
            const Gap(48),
            _editButton(),
            const Gap(16),
            _logoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _logoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: OutlinedButton.icon(
        onPressed: () {
          // Hapus data profil dari Hive
          final profileBox = Hive.box<ProfileModel>(profileBoxName);
          profileBox.delete('userProfile');
          // Tutup aplikasi
          FlutterExitApp.exitApp();
        },
        icon: const Icon(Icons.logout, color: Colors.red),
        label: Text(
          'Log Out',
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

  TextButton _editButton() {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap:  () async {
            // Navigasi ke halaman edit profil
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProfilePage(profile: _profile),
              ),
            );
            // Setelah kembali dari halaman edit, muat ulang data profil
            // untuk menampilkan perubahan.
            _loadProfile();
          },
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
                'Edit Profile',
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

  /// Widget untuk menampilkan data (bukan input).
  Widget _buildDisplayField(String label, String value) {
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
            ),
          ],
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
            // Placeholder agar judul tetap di tengah
            const SizedBox(width: 32),
            Text(
              'My Profile',
              style: GoogleFonts.lexendDeca(
                fontSize: 19,
                fontWeight: FontWeight.w600,
              ),
            ),
            // Placeholder agar judul tetap di tengah
            const SizedBox(width: 32),
          ],
        ),
      ),
    );
  }
}
