import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color ink = Color(0xFF0E1B3D);
  static const Color navy = Color(0xFF155EEF);
  static const Color navyDeep = Color(0xFF0A246B);
  static const Color headerFrom = Color(0xFF071A4A);
  static const Color accentFrom = Color(0xFF7EE787);
  static const Color accentTo = navy;
  static const Color amber = accentFrom;
  static const Color onAccent = Color(0xFFFFFFFF);
  static const Color onNeon = Color(0xFF0A246B);
  static const Color surface = Color(0xFFF3F6FC);
  static const Color mist = Color(0xFFE4EAF8);
  static const Color border = Color(0xFFCDD6EE);
  static const Color muted = Color(0xFF5A6788);
  static const Color success = Color(0xFF2F6F4E);
  static const Color danger = Color(0xFFA33B32);
  static const Color white = Color(0xFFFFFFFF);
  static const Color amberSoft = Color(0x337EE787);
  static const Color successSoft = Color(0x1A2F6F4E);
  static const Color dangerSoft = Color(0x1AA33B32);
  static const Color navySoft = Color(0x14155EEF);
  static const Color navyMuted = Color(0xFFA8B8E0);

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentFrom, navy],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3B7AF5), navy],
  );

  static Color statusBackground(String status) {
    switch (status) {
      case 'published':
      case 'assigned':
      case 'issued':
        return navySoft;
      case 'awarded':
      case 'accepted':
      case 'completed':
      case 'delivered':
      case 'paid':
      case 'active':
        return successSoft;
      case 'submitted':
      case 'in_progress':
      case 'in_transit':
      case 'processing':
      case 'loaded':
      case 'arrived':
      case 'arrived_at_pickup':
      case 'pending_dispatch':
        return amberSoft;
      case 'cancelled':
      case 'expired':
      case 'rejected':
      case 'failed':
      case 'void':
      case 'suspended':
      case 'inactive':
        return dangerSoft;
      default:
        return mist;
    }
  }

  static Color statusForeground(String status) {
    switch (status) {
      case 'published':
      case 'assigned':
      case 'issued':
        return navy;
      case 'awarded':
      case 'accepted':
      case 'completed':
      case 'delivered':
      case 'paid':
      case 'active':
        return success;
      case 'submitted':
      case 'in_progress':
      case 'in_transit':
      case 'processing':
      case 'loaded':
      case 'arrived':
      case 'arrived_at_pickup':
      case 'pending_dispatch':
        return onNeon;
      case 'cancelled':
      case 'expired':
      case 'rejected':
      case 'failed':
      case 'void':
      case 'suspended':
      case 'inactive':
        return danger;
      default:
        return muted;
    }
  }
}
