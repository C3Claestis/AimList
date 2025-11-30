// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

class Navbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const Navbar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 83, // Beri ruang yang cukup untuk tombol yang menonjol ke atas
      child: Stack(        
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // BACKGROUND NAVBAR
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(              
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(      
                  alignment: Alignment.topCenter,          
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/navbar.png'),
                      fit: BoxFit.cover,
                    ),                    
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _navIcon(
                          svgPath: 'assets/svgs/homeBtn.svg',
                          isActive: currentIndex == 0, 
                          onTap: () => onTap(0),
                        ),
                        _navIcon(
                          svgPath: 'assets/svgs/calenderBtn.svg',
                          isActive: currentIndex == 1,
                          onTap: () => onTap(1),
                        ),
                        const Gap(51),
                        _navIcon(
                          svgPath: 'assets/svgs/documentBtn.svg',
                          isActive: currentIndex == 2,
                          onTap: () => onTap(2),
                        ),
                        _navIcon(
                          svgPath: 'assets/svgs/profileBtn.svg',
                          isActive: currentIndex == 3,
                          onTap: () => onTap(3),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // TOMBOL TENGAH
          Positioned(
            top: 0,
            child: GestureDetector(
              onTap: () => onTap(99), // custom index untuk tombol tengah
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF6B33FF),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6B33FF).withOpacity(0.6),
                      blurRadius: 15,
                      spreadRadius: 3,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------
  // NAV ICON
  // ----------------------------------------
  Widget _navIcon({
    IconData? icon,
    String? svgPath,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final color = isActive
        ? const Color(0xFF6B33FF)
        : Colors.black.withOpacity(0.25);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: svgPath != null
          ? SvgPicture.asset(
              svgPath,
              width: 24,
              height: 24,
              color: color,
            )
          : Icon(
              icon,
              size: 24,
              color: color,
            ),
    );
  }
}
