// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';

class PageWidget extends StatelessWidget {
  final Widget child;
  final Widget? bottomNavBar;

  final bool isSpalashScreen;

  const PageWidget({
    super.key,
    required this.isSpalashScreen,
    required this.child,
    this.bottomNavBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,   
      bottomNavigationBar: bottomNavBar,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (isSpalashScreen) ...[
              Positioned(
                left: -15,
                top: 126,
                child: _bluredCircle(colors: 0xFF46F08A, lebar: 70, tinggi: 70),
              ),
              Positioned(
                left: 263,
                child: _bluredCircle(colors: 0xFFF0E946, lebar: 70, tinggi: 70),
              ),
              Positioned(
                left: 333,
                top: 232,
                child: _bluredCircle(colors: 0xFF2555FF, lebar: 60, tinggi: 60),
              ),
              Positioned(
                left: 76,
                bottom: 424,
                child: _bluredCircle(colors: 0xFF46B3F0, lebar: 58, tinggi: 58),
              ),
              Positioned(
                left: 240,
                top: 767,
                child: _bluredCircle(colors: 0xFFF0CB46, lebar: 58, tinggi: 58),
              ),
            ] else ...[
              Positioned(
                top: -14,
                left: -16,
                child: _bluredCircle(colors: 0xFF46F08A, lebar: 70, tinggi: 70),
              ),
              Positioned(
                top: 331,
                left: 304,
                child: _bluredCircle(colors: 0xFFF0E946, lebar: 118, tinggi: 118),
              ),
              Positioned(
                top: 767,
                left: 240,
                child: _bluredCircle(colors: 0xFFF0CB46, lebar: 58, tinggi: 58),
              ),
              Positioned(
                top: 210,
                left: 72,
                child: _bluredCircle(colors: 0xFF5F27FF, lebar: 74, tinggi: 74),
              ),
              Positioned(
                top: 540,
                left: -29,
                child: _bluredCircle(colors: 0xFF46BDF0, lebar: 96, tinggi: 96),
              ),
               Positioned(
                top: 232,
                left: 333,
                child: _bluredCircle(colors: 0xFF7C46F0, lebar: 60, tinggi: 60),
              ),
            ],
            child,
          ],
        ),
      ),
    );
  }

  Container _bluredCircle({
    required int colors,
    required double lebar,
    required double tinggi,
  }) {
    return Container(
      width: lebar,
      height: tinggi,
      decoration: BoxDecoration(
        color: Color(colors),
        borderRadius: BorderRadius.circular(161 / 2),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
        child: Container(),
      ),
    );
  }
}
