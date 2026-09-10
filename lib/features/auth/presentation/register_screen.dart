import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/i18n/i18n_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../data/auth_models.dart';
import 'auth_controller.dart';
import 'auth_layout.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _company = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String _accountType = 'individual';
  bool _obscure = true;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _company.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting || !(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).register(
            RegisterCustomerPayload(
              name: _name.text.trim(),
              email: _email.text.trim(),
              password: _password.text,
              passwordConfirmation: _confirm.text,
              accountType: _accountType,
              companyName: _accountType == 'company' ? _company.text.trim() : null,
              phone: _phone.text.trim(),
              locale: ref.read(i18nControllerProvider).value?.locale.languageCode ?? 'en',
            ),
          );
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _mapError(error));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _mapError(Object error) {
    if (error is ApiException) {
      if (error.message == 'network') {
        return ref.i18n.t('common.networkError');
      }
      return error.fieldError('email') ??
          error.fieldError('password') ??
          error.fieldError('company_name') ??
          error.message;
    }
    return error.toString();
  }

  @override
  Widget build(BuildContext context) {
    final i18n = ref.i18n;
    return AuthLayout(
      title: i18n.t('auth.registerTitle'),
      subtitle: i18n.t('auth.registerSubtitle'),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'individual', label: Text(i18n.t('auth.individual'))),
                ButtonSegment(value: 'company', label: Text(i18n.t('auth.company'))),
              ],
              selected: {_accountType},
              onSelectionChanged: (value) => setState(() => _accountType = value.first),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: i18n.t('auth.fullName'),
              controller: _name,
              textInputAction: TextInputAction.next,
              validator: (value) =>
                  value == null || value.trim().isEmpty ? i18n.t('auth.nameRequired') : null,
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: i18n.t('auth.email'),
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) return i18n.t('auth.emailRequired');
                if (!value.contains('@')) return i18n.t('auth.emailInvalid');
                return null;
              },
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: i18n.t('auth.phone'),
              controller: _phone,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
            ),
            if (_accountType == 'company') ...[
              const SizedBox(height: 14),
              AppTextField(
                label: i18n.t('auth.companyName'),
                controller: _company,
                textInputAction: TextInputAction.next,
                validator: (value) =>
                    value == null || value.trim().isEmpty ? i18n.t('auth.companyRequired') : null,
              ),
            ],
            const SizedBox(height: 14),
            AppTextField(
              label: i18n.t('auth.password'),
              controller: _password,
              obscureText: _obscure,
              textInputAction: TextInputAction.next,
              suffix: IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return i18n.t('auth.passwordRequired');
                if (value.length < 8) return i18n.t('auth.passwordShort');
                return null;
              },
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: i18n.t('auth.passwordConfirm'),
              controller: _confirm,
              obscureText: _obscure,
              validator: (value) {
                if (value != _password.text) return i18n.t('auth.passwordMismatch');
                return null;
              },
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: AppColors.danger)),
            ],
            const SizedBox(height: 18),
            AppButton(
              label: _submitting ? i18n.t('auth.creatingAccount') : i18n.t('auth.register'),
              loading: _submitting,
              expanded: true,
              onPressed: _submit,
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(i18n.t('auth.hasAccount'), style: const TextStyle(color: AppColors.muted)),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text(i18n.t('auth.login')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
