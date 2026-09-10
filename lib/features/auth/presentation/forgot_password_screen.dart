import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/i18n/i18n_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import 'auth_controller.dart';
import 'auth_layout.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _submitting = false;
  String? _error;
  String? _success;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting || !(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _submitting = true;
      _error = null;
      _success = null;
    });
    try {
      await ref.read(authRepositoryProvider).forgotPassword(_email.text.trim());
      if (!mounted) return;
      setState(() => _success = ref.i18n.t('auth.resetSent'));
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error is ApiException && error.message == 'network'
            ? ref.i18n.t('common.networkError')
            : error.toString();
      });
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final i18n = ref.i18n;
    return AuthLayout(
      title: i18n.t('auth.forgotPassword'),
      subtitle: i18n.t('auth.forgotSubtitle'),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: i18n.t('auth.email'),
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) return i18n.t('auth.emailRequired');
                if (!value.contains('@')) return i18n.t('auth.emailInvalid');
                return null;
              },
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: AppColors.danger)),
            ],
            if (_success != null) ...[
              const SizedBox(height: 12),
              Text(_success!, style: const TextStyle(color: AppColors.success)),
            ],
            const SizedBox(height: 18),
            AppButton(
              label: _submitting ? i18n.t('auth.sending') : i18n.t('auth.sendReset'),
              loading: _submitting,
              expanded: true,
              onPressed: _submit,
            ),
            const SizedBox(height: 8),
            AppButton(
              label: i18n.t('auth.login'),
              variant: AppButtonVariant.ghost,
              onPressed: () => context.go('/login'),
            ),
          ],
        ),
      ),
    );
  }
}
