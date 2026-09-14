import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/i18n_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../invoices/presentation/invoices_screen.dart';
import 'payments_screen.dart';

class BillingScreen extends ConsumerWidget {
  const BillingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = ref.i18n;
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Material(
              color: AppColors.mist,
              borderRadius: BorderRadius.circular(AppTheme.radius),
              child: TabBar(
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  border: Border.all(color: AppColors.border),
                ),
                labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                tabs: [
                  Tab(text: i18n.t('invoice.title')),
                  Tab(text: i18n.t('payment.title')),
                ],
              ),
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [
                InvoicesScreen(),
                PaymentsScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
