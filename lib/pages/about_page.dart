// ignore_for_file: deprecated_member_use, avoid_print

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todolist_app/services/page_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  // Fungsi untuk membuka URL
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // Bisa ditambahkan notifikasi jika gagal membuka URL
      print('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageWidget(
      isSpalashScreen: false,
      child: Column(
        children: [
          _header(context),
          const Gap(24),
          _imageApp(),
          const Gap(16),
          _nameApp(),
          const Gap(4),
          _versionApp(),
          const Gap(24),
          _descriptionApp(),
          const Gap(32),
          _contactMe(),
          const Gap(12),
          SizedBox(
            width: 144,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Ganti 'YOUR_DISCORD_INVITE_OR_PROFILE_URL' dengan URL Discord Anda
                IconButton(
                  onPressed: () => _launchURL('https://discord.com/users/mjs5293'),
                  icon: const Icon(Icons.discord,
                      size: 32, color: Color(0xFF5F33E1)),
                ),
                // Membuka WhatsApp ke nomor yang diberikan
                IconButton(
                  onPressed: () => _launchURL('https://wa.me/628812553446'),
                  icon: Image.asset(
                    'assets/images/WhatsApp.png',
                    height: 32,
                    width: 32,
                  ),
                ),
                // Ganti 'your_instagram_username' dengan username Instagram Anda
                IconButton(
                  onPressed: () =>
                      _launchURL('https://www.instagram.com/mjsidiq'),
                  icon: Image.asset(
                    'assets/images/Instagram.png',
                    height: 32,
                    width: 32,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(), // Mendorong widget di bawahnya ke bagian bawah
          _footer(),
          const Gap(16), // Memberi sedikit jarak dari bagian bawah layar
        ],
      ),
    );
  }

  CircleAvatar _imageApp() {
    return CircleAvatar(
          radius: 54,
          backgroundImage: const AssetImage('assets/images/Chisa.jpeg'),
        );
  }

  Text _nameApp() {
    return Text(
          'AimList',
          style: GoogleFonts.lexendDeca(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        );
  }

  Text _versionApp() {
    return Text(
          'Version 1.0.0',
          style: GoogleFonts.lexendDeca(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        );
  }

  Padding _descriptionApp() {
    return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            'This application is designed to help you manage tasks and projects more easily and efficiently. With a clean and intuitive interface, you can focus on what really matters.',
            textAlign: TextAlign.center,
            style: GoogleFonts.lexendDeca(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        );
  }

  Text _contactMe() {
    return Text(
          'Connect with me',
          style: GoogleFonts.lexendDeca(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        );
  }

  Text _footer() {
    return Text(
          'Desain from Figma Community and Image From Wuthering Waves',
          style: GoogleFonts.lexendDeca(
            fontSize: 11,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.normal,
          ),
        );
  }

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
              'About',
              style: GoogleFonts.lexendDeca(
                fontSize: 19,
                fontWeight: FontWeight.w600,
              ),
            ),
            Stack(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: SvgPicture.asset(
                    'assets/svgs/notif.svg',
                    fit: BoxFit.cover,
                    color: Colors.black,
                    width: 24,
                    height: 24,
                  ),
                ),
                // Bulatan merah di pojok kanan atas
                Positioned(
                  right: 15,
                  top: 12,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFF5F33E1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
