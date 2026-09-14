import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/i18n/i18n_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../profile_helpers.dart';

Future<bool> showEditAccountSheet({
  required BuildContext context,
  required I18nBundle i18n,
  required String name,
  required String phone,
  required Future<void> Function(String name, String phone) onSave,
}) async {
  final saved = await showProfileSheet<bool>(
    context: context,
    builder: (context) {
      return _EditAccountSheet(
        i18n: i18n,
        initialName: name,
        initialPhone: phone,
        onSave: onSave,
      );
    },
  );
  return saved == true;
}

Future<bool> showChangePasswordSheet({
  required BuildContext context,
  required I18nBundle i18n,
  required Future<void> Function({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) onSave,
}) async {
  final saved = await showProfileSheet<bool>(
    context: context,
    builder: (context) {
      return _ChangePasswordSheet(i18n: i18n, onSave: onSave);
    },
  );
  return saved == true;
}

class _EditAccountSheet extends StatefulWidget {
  const _EditAccountSheet({
    required this.i18n,
    required this.initialName,
    required this.initialPhone,
    required this.onSave,
  });

  final I18nBundle i18n;
  final String initialName;
  final String initialPhone;
  final Future<void> Function(String name, String phone) onSave;

  @override
  State<_EditAccountSheet> createState() => _EditAccountSheetState();
}

class _EditAccountSheetState extends State<_EditAccountSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  bool _saving = false;
  String? _error;

  I18nBundle get _i18n => widget.i18n;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initialName);
    _phone = TextEditingController(text: widget.initialPhone);
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving || !(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onSave(_name.text.trim(), _phone.text.trim());
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = mapProfileError(error, _i18n, const ['name', 'phone']);
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SheetScaffold(
      title: _i18n.t('profile.editAccount'),
      hint: _i18n.t('profile.accountHint'),
      error: _error,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: _i18n.t('profile.name'),
              controller: _name,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              inputFormatters: [LengthLimitingTextInputFormatter(120)],
              validator: (value) => value == null || value.trim().isEmpty
                  ? _i18n.t('auth.nameRequired')
                  : null,
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: _i18n.t('common.phone'),
              controller: _phone,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              textDirection: TextDirection.ltr,
              autofillHints: const [AutofillHints.telephoneNumber],
              inputFormatters: [LengthLimitingTextInputFormatter(32)],
            ),
            const SizedBox(height: 20),
            AppButton(
              label: _i18n.t('common.save'),
              icon: Icons.check,
              loading: _saving,
              expanded: true,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet({
    required this.i18n,
    required this.onSave,
  });

  final I18nBundle i18n;
  final Future<void> Function({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) onSave;

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _saving = false;
  String? _error;

  I18nBundle get _i18n => widget.i18n;

  @override
  void dispose() {
    _currentPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving || !(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onSave(
        currentPassword: _currentPassword.text,
        password: _newPassword.text,
        passwordConfirmation: _confirmPassword.text,
      );
      if (!mounted) return;
      TextInput.finishAutofillContext();
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = mapProfileError(error, _i18n, const [
          'current_password',
          'password',
          'password_confirmation',
        ]);
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SheetScaffold(
      title: _i18n.t('profile.password'),
      hint: _i18n.t('profile.passwordSectionHint'),
      error: _error,
      child: ListenableBuilder(
        listenable: _newPassword,
        builder: (context, _) {
          final newValue = _newPassword.text;
          final hint = newValue.isEmpty
              ? _i18n.t('profile.passwordHint')
              : newValue.length < 8
                  ? _i18n.t('auth.passwordShort')
                  : _i18n.t('profile.passwordOk');
          final hintColor = newValue.isNotEmpty && newValue.length < 8
              ? AppColors.danger
              : newValue.length >= 8
                  ? AppColors.success
                  : AppColors.muted;

          return AutofillGroup(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PasswordStrengthBar(value: newValue),
                  const SizedBox(height: 8),
                  Text(
                    hint,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: hintColor,
                          height: 1.4,
                        ),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: _i18n.t('profile.currentPassword'),
                    controller: _currentPassword,
                    obscureText: _obscureCurrent,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.password],
                    suffix: passwordVisibilityToggle(
                      i18n: _i18n,
                      obscure: _obscureCurrent,
                      onToggle: () =>
                          setState(() => _obscureCurrent = !_obscureCurrent),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? _i18n.t('auth.passwordRequired')
                        : null,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    label: _i18n.t('profile.newPassword'),
                    controller: _newPassword,
                    obscureText: _obscureNew,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.newPassword],
                    suffix: passwordVisibilityToggle(
                      i18n: _i18n,
                      obscure: _obscureNew,
                      onToggle: () => setState(() => _obscureNew = !_obscureNew),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return _i18n.t('auth.passwordRequired');
                      }
                      if (value.length < 8) return _i18n.t('auth.passwordShort');
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    label: _i18n.t('profile.confirmPassword'),
                    controller: _confirmPassword,
                    obscureText: _obscureConfirm,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.newPassword],
                    suffix: passwordVisibilityToggle(
                      i18n: _i18n,
                      obscure: _obscureConfirm,
                      onToggle: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return _i18n.t('auth.passwordRequired');
                      }
                      if (value != _newPassword.text) {
                        return _i18n.t('auth.passwordMismatch');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    label: _i18n.t('profile.updatePassword'),
                    icon: Icons.lock_reset_outlined,
                    loading: _saving,
                    expanded: true,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SheetScaffold extends StatelessWidget {
  const _SheetScaffold({
    required this.title,
    required this.hint,
    required this.child,
    this.error,
  });

  final String title;
  final String hint;
  final Widget child;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              hint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.muted,
                    height: 1.35,
                  ),
            ),
            if (error != null && error!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.dangerSoft,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Text(
                  error!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
