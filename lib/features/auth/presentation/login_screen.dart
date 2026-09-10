import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/i18n/i18n_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import 'auth_controller.dart';
import 'auth_layout.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting || !(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).login(
            _email.text.trim(),
            _password.text,
          );
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _mapError(error));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _mapError(Object error) {
    final i18n = ref.read(i18nControllerProvider).value;
    if (error is ApiException) {
      if (error.message == 'network') {
        return i18n?.t('common.networkError') ?? error.message;
      }
      return error.message;
    }
    return error.toString();
  }

  @override
  Widget build(BuildContext context) {
    final i18n = ref.i18n;
    return AuthLayout(
      title: i18n.t('auth.welcome'),
      subtitle: i18n.t('auth.welcomeSubtitle'),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: i18n.t('auth.email'),
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return i18n.t('auth.emailRequired');
                }
                if (!value.contains('@')) return i18n.t('auth.emailInvalid');
                return null;
              },
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: i18n.t('auth.password'),
              controller: _password,
              obscureText: _obscure,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              onChanged: (_) {},
              suffix: IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return i18n.t('auth.passwordRequired');
                return null;
              },
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: () => context.go('/forgot-password'),
                child: Text(i18n.t('auth.forgotPassword')),
              ),
            ),
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: AppColors.danger)),
              const SizedBox(height: 12),
            ],
            AppButton(
              label: _submitting ? i18n.t('auth.signingIn') : i18n.t('auth.login'),
              loading: _submitting,
              expanded: true,
              onPressed: _submit,
            ),
            const SizedBox(height: 8),
            AppButton(
              label: i18n.t('auth.useDemo'),
              variant: AppButtonVariant.secondary,
              expanded: true,
              onPressed: _submitting
                  ? null
                  : () {
                      _email.text = AppConstants.demoEmail;
                      _password.text = AppConstants.demoPassword;
                      _submit();
                    },
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(i18n.t('auth.noAccount'), style: const TextStyle(color: AppColors.muted)),
                TextButton(
                  onPressed: () => context.go('/register'),
                  child: Text(i18n.t('auth.register')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
