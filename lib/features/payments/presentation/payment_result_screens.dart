import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/i18n_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../../jobs/presentation/job_providers.dart';
import '../data/payment_repository.dart';
import 'payment_providers.dart';

class PaymentSuccessScreen extends ConsumerStatefulWidget {
  const PaymentSuccessScreen({
    super.key,
    this.paymentId,
    this.jobId,
    this.success = true,
  });

  final int? paymentId;
  final int? jobId;
  final bool success;

  @override
  ConsumerState<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends ConsumerState<PaymentSuccessScreen> {
  bool _checking = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolve());
  }

  Future<void> _resolve() async {
    if (widget.jobId != null && widget.success) {
      ref.invalidate(jobsProvider);
      ref.invalidate(paymentsProvider);
      if (!mounted) return;
      context.go('/jobs/${widget.jobId}');
      return;
    }

    final paymentId = widget.paymentId;
    if (paymentId == null) return;

    setState(() {
      _checking = true;
      _error = null;
    });
    try {
      final result = await ref.read(paymentRepositoryProvider).status(paymentId);
      if (!mounted) return;
      ref.invalidate(jobsProvider);
      ref.invalidate(paymentsProvider);
      if (result.job != null) {
        context.go('/jobs/${result.job!.id}');
        return;
      }
      setState(() {
        _checking = false;
        _error = ref.i18n.t('payment.pendingConfirmation');
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _checking = false;
        _error = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final i18n = ref.i18n;
    return PageScaffold(
      title: i18n.t('payment.successTitle'),
      body: ContentWidth(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.success ? i18n.t('payment.successBody') : i18n.t('payment.pendingConfirmation'),
                style: const TextStyle(color: AppColors.muted, height: 1.5),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!, style: const TextStyle(color: AppColors.danger)),
              ],
              const SizedBox(height: 24),
              AppButton(
                label: i18n.t('payment.checkStatus'),
                loading: _checking,
                expanded: true,
                onPressed: _resolve,
              ),
              const SizedBox(height: 12),
              AppButton(
                label: i18n.t('payment.viewPayments'),
                variant: AppButtonVariant.ghost,
                expanded: true,
                onPressed: () => context.go('/payments'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PaymentCancelScreen extends ConsumerWidget {
  const PaymentCancelScreen({super.key, this.paymentId});

  final int? paymentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = ref.i18n;
    return PageScaffold(
      title: i18n.t('payment.cancelTitle'),
      body: ContentWidth(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                i18n.t('payment.cancelBody'),
                style: const TextStyle(color: AppColors.muted, height: 1.5),
              ),
              const SizedBox(height: 24),
              AppButton(
                label: i18n.t('payment.viewPayments'),
                expanded: true,
                onPressed: () => context.go('/payments'),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: i18n.t('nav.shipments'),
                variant: AppButtonVariant.ghost,
                expanded: true,
                onPressed: () => context.go('/shipments'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
