import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TodayHeader extends StatelessWidget {
  final String content;
  final bool isSelected;
  final VoidCallback? onTap;

  const TodayHeader({
    super.key,
    required this.content,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),            
            image: isSelected
                ? const DecorationImage(
                    image: AssetImage("assets/images/Rectangle.png"),
                    fit: BoxFit.fill,
                  )
                : const DecorationImage(
                    image: AssetImage("assets/images/Rectangle_2.png"),
                    fit: BoxFit.fill,
                  ),
          ),
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              content,
              style: GoogleFonts.lexendDeca(
                color: isSelected ? Colors.white : const Color(0xFF5F33E1),
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
