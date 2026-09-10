import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import '../storage/settings_storage.dart';

class I18nBundle {
  const I18nBundle({
    required this.locale,
    required this.strings,
  });

  final Locale locale;
  final Map<String, String> strings;

  bool get isRtl => locale.languageCode == 'ar';
  TextDirection get textDirection =>
      isRtl ? TextDirection.rtl : TextDirection.ltr;

  String t(String key, [Map<String, String>? args]) {
    var value = strings[key] ?? key;
    args?.forEach((name, replacement) {
      value = value.replaceAll('{$name}', replacement);
    });
    return value;
  }

  String status(String? raw) {
    if (raw == null || raw.isEmpty) return t('common.notAvailable');
    return t('status.$raw');
  }
}

class I18nController extends AsyncNotifier<I18nBundle> {
  @override
  Future<I18nBundle> build() async {
    var code = 'en';
    try {
      final settings = await ref
          .watch(settingsStorageProvider.future)
          .timeout(const Duration(seconds: 2));
      code = settings.localeCode();
    } catch (_) {
      // SharedPreferences can hang on some Android devices. Fall back to English.
    }
    return _load(code);
  }

  Future<void> setLocale(String code) async {
    if (!AppConstants.supportedLocales.contains(code)) return;
    final settings = await ref.read(settingsStorageProvider.future);
    await settings.setLocaleCode(code);
    state = AsyncData(await _load(code));
  }

  Future<I18nBundle> _load(String code) async {
    final json = await rootBundle.loadString('assets/i18n/$code.json');
    final decoded = jsonDecode(json) as Map<String, dynamic>;
    return I18nBundle(
      locale: Locale(code),
      strings: decoded.map((key, value) => MapEntry(key, value.toString())),
    );
  }
}

final i18nControllerProvider =
    AsyncNotifierProvider<I18nController, I18nBundle>(I18nController.new);

extension I18nRefX on WidgetRef {
  I18nBundle get i18n {
    return watch(i18nControllerProvider).maybeWhen(
      data: (bundle) => bundle,
      orElse: () => const I18nBundle(
        locale: Locale('en'),
        strings: {},
      ),
    );
  }

  String tr(String key, [Map<String, String>? args]) => i18n.t(key, args);
}
