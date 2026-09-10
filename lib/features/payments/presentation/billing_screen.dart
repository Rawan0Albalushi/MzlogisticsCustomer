import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/i18n_controller.dart';
import '../../../core/theme/app_colors.dart';
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
          Material(
            color: AppColors.white,
            child: TabBar(
              tabs: [
                Tab(text: i18n.t('invoice.title')),
                Tab(text: i18n.t('payment.title')),
              ],
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
