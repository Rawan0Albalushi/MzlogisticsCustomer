import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mz_logistics_customer_app/core/theme/app_colors.dart';
import 'package:mz_logistics_customer_app/core/utils/formatters.dart';

void main() {
  test('brand colors stay on the navy and neon palette', () {
    expect(AppColors.ink, const Color(0xFF0E1B3D));
    expect(AppColors.navy, const Color(0xFF155EEF));
    expect(AppColors.accentFrom, const Color(0xFF7EE787));
    expect(AppColors.accentTo, const Color(0xFF155EEF));
    expect(AppColors.amber, AppColors.accentFrom);
  });

  test('amount formatter includes currency', () {
    expect(formatAmount(12.5), contains('OMR'));
  });
}
