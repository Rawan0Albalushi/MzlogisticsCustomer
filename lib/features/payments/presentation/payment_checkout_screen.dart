import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/i18n/i18n_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../data/checkout_launcher.dart';
import '../data/checkout_webview.dart';
import '../data/payment_repository.dart';
import '../data/payment_return.dart';
import 'payment_providers.dart';

class PaymentCheckoutScreen extends ConsumerStatefulWidget {
  const PaymentCheckoutScreen({
    super.key,
    required this.paymentId,
    this.paymentLink,
  });

  final int paymentId;
  final String? paymentLink;

  @override
  ConsumerState<PaymentCheckoutScreen> createState() => _PaymentCheckoutScreenState();
}

class _PaymentCheckoutScreenState extends ConsumerState<PaymentCheckoutScreen> {
  Timer? _poll;
  WebViewController? _webView;
  bool _opening = false;
  bool _finished = false;
  bool _pageReady = false;
  String? _error;
  String? _checkoutUrl;

  bool get _useInAppCheckout => !kIsWeb && (_checkoutUrl?.isNotEmpty ?? false);

  @override
  void initState() {
    super.initState();
    _checkoutUrl = widget.paymentLink;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_useInAppCheckout) {
        unawaited(_prepareWebView());
      } else {
        unawaited(_recoverCheckout());
      }
    });
    _poll = Timer.periodic(const Duration(seconds: 2), (_) => _checkStatus());
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  void _handleReturnUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (PaymentReturn.isAppReturn(uri) || PaymentReturn.isApiCallback(uri)) {
      _finish(uri);
    }
  }

  Future<void> _prepareWebView() async {
    final url = _checkoutUrl;
    if (url == null || url.isEmpty) return;
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri != null && PaymentReturn.isAppReturn(uri)) {
              _finish(uri);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageStarted: (started) {
            if (!mounted || _finished) return;
            final uri = Uri.tryParse(started);
            if (uri != null && (PaymentReturn.isAppReturn(uri) || PaymentReturn.isApiCallback(uri))) {
              return;
            }
            setState(() {
              _pageReady = false;
              _error = null;
            });
          },
          onPageFinished: (finished) {
            _handleReturnUrl(finished);
            if (!mounted || _finished) return;
            final uri = Uri.tryParse(finished);
            if (uri != null && (PaymentReturn.isAppReturn(uri) || PaymentReturn.isApiCallback(uri))) {
              return;
            }
            setState(() => _pageReady = true);
          },
          onUrlChange: (change) {
            final next = change.url;
            if (next != null) {
              final uri = Uri.tryParse(next);
              if (uri != null && PaymentReturn.isAppReturn(uri)) {
                _finish(uri);
              }
            }
          },
          onWebResourceError: (error) {
            final failed = error.url;
            if (failed == null) return;
            final uri = Uri.tryParse(failed);
            if (uri != null && PaymentReturn.isAppReturn(uri)) {
              _finish(uri);
            }
          },
        ),
      );
    await configureCheckoutWebView(controller);
    await controller.loadRequest(Uri.parse(url));
    if (!mounted) return;
    setState(() => _webView = controller);
  }

  Future<void> _recoverCheckout() async {
    if (_finished) return;
    try {
      final result = await ref.read(paymentRepositoryProvider).status(widget.paymentId);
      if (!mounted || _finished) return;
      if (result.isPaid && result.job != null) {
        _finished = true;
        _poll?.cancel();
        ref.invalidate(paymentsProvider);
        context.go('/jobs/${result.job!.id}');
        return;
      }
      final link = result.payment?.paymentLink;
      if (!kIsWeb && link != null && link.isNotEmpty) {
        _checkoutUrl = link;
        await _prepareWebView();
        return;
      }
    } catch (_) {
      // Fall through to the external-browser fallback.
    }
    await _openExternalCheckout();
  }

  Future<void> _openExternalCheckout() async {
    final link = _checkoutUrl ?? widget.paymentLink;
    if (link == null || link.isEmpty) return;
    setState(() {
      _opening = true;
      _error = null;
    });
    try {
      final opened = await openThawaniCheckout(link);
      if (!opened && mounted) {
        setState(() => _error = ref.i18n.t('payment.checkoutOpenFailed'));
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = ref.i18n.t('payment.checkoutOpenFailed'));
      }
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  Future<void> _finish(Uri uri) async {
    if (_finished || !mounted) return;
    _finished = true;
    _poll?.cancel();
    if (PaymentReturn.isCancel(uri)) {
      context.go('/payment/cancel?payment_id=${widget.paymentId}');
      return;
    }
    context.go('/payment/success?payment_id=${widget.paymentId}');
  }

  Future<void> _checkStatus() async {
    if (_finished) return;
    try {
      final result = await ref.read(paymentRepositoryProvider).status(widget.paymentId);
      if (!mounted || _finished) return;
      if (result.isPaid && result.job != null) {
        _finished = true;
        _poll?.cancel();
        ref.invalidate(paymentsProvider);
        context.go('/jobs/${result.job!.id}');
      }
    } catch (_) {
      // Keep polling until checkout finishes or the user cancels.
    }
  }

  @override
  Widget build(BuildContext context) {
    final i18n = ref.i18n;
    if (_useInAppCheckout) {
      return Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          title: Text(i18n.t('payment.checkoutTitle')),
          leading: IconButton(
            icon: const Icon(Icons.close),
            tooltip: i18n.t('common.cancel'),
            onPressed: () => context.go('/payment/cancel?payment_id=${widget.paymentId}'),
          ),
          actions: [
            TextButton(
              onPressed: _opening ? null : _openExternalCheckout,
              child: Text(i18n.t('payment.openInBrowser')),
            ),
          ],
        ),
        body: Stack(
          children: [
            if (_webView != null) Positioned.fill(child: buildCheckoutWebView(_webView!)),
            if (!_pageReady && _error == null)
              ColoredBox(
                color: AppColors.white,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        i18n.t('payment.checkoutLoading'),
                        style: const TextStyle(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ),
            if (_error != null)
              ColoredBox(
                color: AppColors.white,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.danger, height: 1.5),
                        ),
                        const SizedBox(height: 20),
                        AppButton(
                          label: i18n.t('payment.openInBrowser'),
                          loading: _opening,
                          expanded: true,
                          onPressed: _openExternalCheckout,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return PageScaffold(
      title: i18n.t('payment.checkoutTitle'),
      body: ContentWidth(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                i18n.t('payment.checkoutBody'),
                style: const TextStyle(color: AppColors.muted, height: 1.5),
              ),
              const SizedBox(height: 24),
              if (_error != null) ...[
                Text(_error!, style: const TextStyle(color: AppColors.danger)),
                const SizedBox(height: 16),
              ],
              AppButton(
                label: i18n.t('payment.openCheckout'),
                loading: _opening,
                expanded: true,
                onPressed: _openExternalCheckout,
              ),
              const SizedBox(height: 12),
              AppButton(
                label: i18n.t('payment.checkStatus'),
                variant: AppButtonVariant.secondary,
                expanded: true,
                onPressed: _checkStatus,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
