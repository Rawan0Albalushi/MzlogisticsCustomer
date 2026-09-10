import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

final settingsStorageProvider = FutureProvider<SettingsStorage>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return SettingsStorage(prefs);
});

class SettingsStorage {
  SettingsStorage(this._prefs);

  final SharedPreferences _prefs;

  String localeCode() => _prefs.getString(AppConstants.localeKey) ?? 'en';

  Future<void> setLocaleCode(String code) {
    return _prefs.setString(AppConstants.localeKey, code);
  }
}
