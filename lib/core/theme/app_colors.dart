import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color ink = Color(0xFF10212C);
  static const Color navy = Color(0xFF0E2A38);
  static const Color navyDeep = Color(0xFF0A1F2A);
  static const Color amber = Color(0xFFC9892C);
  static const Color surface = Color(0xFFF5F6F8);
  static const Color mist = Color(0xFFE7EDF1);
  static const Color border = Color(0xFFD8E0E6);
  static const Color muted = Color(0xFF5B6B76);
  static const Color success = Color(0xFF2F6F4E);
  static const Color danger = Color(0xFFA33B32);
  static const Color white = Color(0xFFFFFFFF);
  static const Color amberSoft = Color(0x1AC9892C);
  static const Color successSoft = Color(0x1A2F6F4E);
  static const Color dangerSoft = Color(0x1AA33B32);
  static const Color navySoft = Color(0x1412202B);
  static const Color navyMuted = Color(0xFF8AA0AD);

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
        return const Color(0xFF8A5E16);
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
