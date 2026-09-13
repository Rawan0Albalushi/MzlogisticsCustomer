import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mz_logistics_customer_app/core/theme/app_colors.dart';
import 'package:mz_logistics_customer_app/core/utils/formatters.dart';

void main() {
  test('brand colors stay on the logistics palette', () {
    expect(AppColors.ink, const Color(0xFF0A2A2E));
    expect(AppColors.navy, const Color(0xFF06343A));
    expect(AppColors.accentFrom, const Color(0xFF2EF0D0));
    expect(AppColors.accentTo, const Color(0xFF0891B2));
    expect(AppColors.amber, AppColors.accentTo);
  });

  test('amount formatter includes currency', () {
    expect(formatAmount(12.5), contains('OMR'));
  });
}
