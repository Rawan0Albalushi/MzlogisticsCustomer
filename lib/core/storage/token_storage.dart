import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

final unauthorizedTickProvider = StateProvider<int>((ref) => 0);

class TokenStorage {
  static const _timeout = Duration(seconds: 2);

  Future<SharedPreferences?> _prefs() async {
    try {
      return await SharedPreferences.getInstance().timeout(_timeout);
    } catch (_) {
      return null;
    }
  }

  Future<String?> read() async {
    final prefs = await _prefs();
    return prefs?.getString(AppConstants.tokenKey);
  }

  Future<void> write(String token) async {
    final prefs = await _prefs();
    await prefs?.setString(AppConstants.tokenKey, token);
  }

  Future<void> clear() async {
    final prefs = await _prefs();
    await prefs?.remove(AppConstants.tokenKey);
  }
}
