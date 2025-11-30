import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todolist_app/services/main_frame.dart'; // Ubah import ini
import 'package:todolist_app/services/page_widget.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageWidget(
      isSpalashScreen: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _picture(),
          const Gap(24),
          _tittle(),
          const Gap(20),
          _subtittle(),
          const Gap(40),
          _buttonStart(context),
          const Gap(24),
          Text(
            'Version 1.0.0',
            style: GoogleFonts.lexendDeca(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  SizedBox _subtittle() {
    return SizedBox(
      width: 266,
      child: Text(
        'This productive tool is designed to help \nyou better manage your task\n project-wise conveniently!',
        style: GoogleFonts.lexendDeca(fontSize: 14, letterSpacing: 0 / 100),
        textAlign: TextAlign.center,
      ),
    );
  }

  SizedBox _tittle() {
    return SizedBox(
      width: 247,
      child: Text(
        'Task Management & \nTo-Do List',
        style: GoogleFonts.lexendDeca(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: 0 / 100,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  SizedBox _picture() {
    return SizedBox(
      height: 482,
      width: 408,
      child: Image.asset('assets/images/lets_start.png'),
    );
  }

  TextButton _buttonStart(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const MainFrame(),
          ), // Arahkan ke MainFrame
          (route) => false,
        );
      },
      style: TextButton.styleFrom(padding: EdgeInsets.zero),
      child: Ink(
        width: 331,
        height: 52,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/Rectangle.png"),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: 200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Let’s Start',
                      style: GoogleFonts.lexendDeca(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SvgPicture.asset('assets/svgs/button_start.svg'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
