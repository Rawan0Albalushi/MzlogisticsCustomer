import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/i18n/i18n_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../shared/models/user.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/loading_state.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../../auth/presentation/auth_controller.dart';
import 'widgets/profile_identity_card.dart';
import 'widgets/profile_sections.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _accountFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _currentPassword;
  late final TextEditingController _newPassword;
  late final TextEditingController _confirmPassword;
  bool _saving = false;
  bool _savingPassword = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _initialized = false;
  String _baselineName = '';
  String _baselinePhone = '';

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).user;
    _baselineName = user?.name ?? '';
    _baselinePhone = user?.phone ?? '';
    _name = TextEditingController(text: _baselineName);
    _phone = TextEditingController(text: _baselinePhone);
    _currentPassword = TextEditingController();
    _newPassword = TextEditingController();
    _confirmPassword = TextEditingController();
    _initialized = user != null;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _currentPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  bool get _isAccountDirty {
    return _name.text.trim() != _baselineName ||
        _phone.text.trim() != _baselinePhone;
  }

  void _applyBaseline(UserAccount user) {
    _baselineName = user.name;
    _baselinePhone = user.phone ?? '';
    _name.text = _baselineName;
    _phone.text = _baselinePhone;
  }

  void _syncFields(UserAccount user) {
    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _applyBaseline(user);
      });
      return;
    }
    if (_isAccountDirty) return;
    final serverPhone = user.phone ?? '';
    if (user.name == _baselineName && serverPhone == _baselinePhone) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _isAccountDirty) return;
      _applyBaseline(user);
    });
  }

  void _discardAccountChanges() {
    _name.text = _baselineName;
    _phone.text = _baselinePhone;
  }

  String _mapError(Object error, List<String> fields) {
    if (error is ApiException) {
      if (error.message == 'network') return ref.i18n.t('common.networkError');
      for (final field in fields) {
        final message = error.fieldError(field);
        if (message != null) return message;
      }
      if (error.isUnauthorized) return ref.i18n.t('common.unauthorized');
      return error.message;
    }
    return error.toString();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _save() async {
    if (_saving || !(_accountFormKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(authControllerProvider.notifier)
          .updateProfile(name: _name.text.trim(), phone: _phone.text.trim());
      if (!mounted) return;
      _baselineName = _name.text.trim();
      _baselinePhone = _phone.text.trim();
      _showMessage(ref.i18n.t('profile.saved'));
    } catch (error) {
      if (!mounted) return;
      _showMessage(_mapError(error, const ['name', 'phone']));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _savePassword() async {
    if (_savingPassword ||
        !(_passwordFormKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() => _savingPassword = true);
    try {
      await ref
          .read(authControllerProvider.notifier)
          .updatePassword(
            currentPassword: _currentPassword.text,
            password: _newPassword.text,
            passwordConfirmation: _confirmPassword.text,
          );
      if (!mounted) return;
      _currentPassword.clear();
      _newPassword.clear();
      _confirmPassword.clear();
      TextInput.finishAutofillContext();
      _showMessage(ref.i18n.t('profile.passwordSaved'));
    } catch (error) {
      if (!mounted) return;
      _showMessage(
        _mapError(error, const [
          'current_password',
          'password',
          'password_confirmation',
        ]),
      );
    } finally {
      if (mounted) setState(() => _savingPassword = false);
    }
  }

  Future<void> _changeLocale(String code) async {
    if (code == ref.i18n.locale.languageCode) return;
    await ref.read(i18nControllerProvider.notifier).setLocale(code);
    try {
      await ref
          .read(authControllerProvider.notifier)
          .updateProfile(locale: code);
    } catch (_) {
      // Local language still updates even if the profile sync fails.
    }
    if (!mounted) return;
    _showMessage(ref.i18n.t('profile.localeSaved'));
  }

  Future<void> _logout() async {
    final i18n = ref.i18n;
    final ok = await showConfirmDialog(
      context,
      i18n: i18n,
      title: i18n.t('common.logout'),
      message: i18n.t('common.logoutConfirm'),
      danger: true,
    );
    if (!ok) return;
    await ref.read(authControllerProvider.notifier).logout();
  }

  Future<void> _refresh() {
    return ref.read(authControllerProvider.notifier).refreshProfile();
  }

  @override
  Widget build(BuildContext context) {
    final i18n = ref.i18n;
    final user = ref.watch(authControllerProvider).user;
    if (user == null) {
      return LoadingState(label: i18n.t('common.loading'));
    }
    _syncFields(user);

    final account = ListenableBuilder(
      listenable: Listenable.merge([_name, _phone]),
      builder: (context, _) => ProfileAccountSection(
        i18n: i18n,
        user: user,
        formKey: _accountFormKey,
        name: _name,
        phone: _phone,
        saving: _saving,
        dirty: _isAccountDirty,
        onSave: _save,
        onDiscard: _discardAccountChanges,
      ),
    );
    final password = ListenableBuilder(
      listenable: Listenable.merge([_newPassword]),
      builder: (context, _) => ProfilePasswordSection(
        i18n: i18n,
        formKey: _passwordFormKey,
        currentPassword: _currentPassword,
        newPassword: _newPassword,
        confirmPassword: _confirmPassword,
        obscureCurrent: _obscureCurrent,
        obscureNew: _obscureNew,
        obscureConfirm: _obscureConfirm,
        saving: _savingPassword,
        onToggleCurrent: () =>
            setState(() => _obscureCurrent = !_obscureCurrent),
        onToggleNew: () => setState(() => _obscureNew = !_obscureNew),
        onToggleConfirm: () =>
            setState(() => _obscureConfirm = !_obscureConfirm),
        onSave: _savePassword,
      ),
    );
    final organization = ProfileOrganizationSection(
      i18n: i18n,
      organization: user.organization,
    );
    final language = ProfileLanguageSection(
      i18n: i18n,
      selected: i18n.locale.languageCode,
      onSelected: _changeLocale,
    );
    final session = ProfileSessionSection(i18n: i18n, onLogout: _logout);
    final wide = !context.isMobile;

    const gap = 14.0;

    return ContentWidth(
      child: RefreshIndicator(
        color: AppColors.navy,
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            ProfileIdentityCard(i18n: i18n, user: user),
            const SizedBox(height: 16),
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [account, const SizedBox(height: gap), password],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        organization,
                        const SizedBox(height: gap),
                        language,
                        const SizedBox(height: gap),
                        session,
                      ],
                    ),
                  ),
                ],
              )
            else ...[
              account,
              const SizedBox(height: gap),
              organization,
              const SizedBox(height: gap),
              password,
              const SizedBox(height: gap),
              language,
              const SizedBox(height: gap),
              session,
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
