import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color ink = Color(0xFF0A2A2E);
  static const Color navy = Color(0xFF06343A);
  static const Color navyDeep = Color(0xFF042428);
  static const Color accentFrom = Color(0xFF2EF0D0);
  static const Color accentTo = Color(0xFF0891B2);
  static const Color amber = accentTo;
  static const Color onAccent = Color(0xFF042428);
  static const Color surface = Color(0xFFF2F8F7);
  static const Color mist = Color(0xFFDCEEEB);
  static const Color border = Color(0xFFC5DCDA);
  static const Color muted = Color(0xFF4E6B6A);
  static const Color success = Color(0xFF2F6F4E);
  static const Color danger = Color(0xFFA33B32);
  static const Color white = Color(0xFFFFFFFF);
  static const Color amberSoft = Color(0x1A0891B2);
  static const Color successSoft = Color(0x1A2F6F4E);
  static const Color dangerSoft = Color(0x1AA33B32);
  static const Color navySoft = Color(0x1406343A);
  static const Color navyMuted = Color(0xFF7AA8A6);

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentFrom, accentTo],
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
        return const Color(0xFF0B6B84);
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
