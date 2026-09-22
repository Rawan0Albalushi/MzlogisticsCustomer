import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({
    super.key,
    this.size = 40,
    this.light = false,
  });

  final double size;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final letters = Text(
      'MX',
      style: TextStyle(
        color: light ? AppColors.accentFrom : AppColors.white,
        fontWeight: FontWeight.w800,
        fontSize: size * 0.34,
        letterSpacing: -0.4,
        height: 1,
      ),
    );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: light ? null : AppColors.primaryGradient,
        color: light ? const Color(0x1AFFFFFF) : null,
        borderRadius: BorderRadius.circular(size * 0.28),
        border: light ? Border.all(color: const Color(0x33FFFFFF)) : null,
      ),
      alignment: Alignment.center,
      child: letters,
    );
  }
}
