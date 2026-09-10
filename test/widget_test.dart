import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mz_logistics_customer_app/core/theme/app_colors.dart';
import 'package:mz_logistics_customer_app/core/utils/formatters.dart';

void main() {
  test('brand colors stay on the logistics palette', () {
    expect(AppColors.ink, const Color(0xFF12202B));
    expect(AppColors.navy, const Color(0xFF0F2C3C));
    expect(AppColors.amber, const Color(0xFFC9892C));
  });

  test('amount formatter includes currency', () {
    expect(formatAmount(12.5), contains('OMR'));
  });
}
