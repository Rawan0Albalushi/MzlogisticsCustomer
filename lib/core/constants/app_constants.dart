class AppConstants {
  AppConstants._();

  static const String _apiBaseUrlFromEnv = String.fromEnvironment('API_BASE_URL');
  static const String _storageBaseUrlFromEnv = String.fromEnvironment('STORAGE_BASE_URL');

  /// Optional PC Wi-Fi IPv4 for a physical phone over the same network.
  /// USB debugging does not need this: run `adb reverse tcp:8000 tcp:8000`.
  static const String devLanHost = String.fromEnvironment('DEV_LAN_HOST');

  static const int apiPort = 8000;

  static String get apiHost {
    if (_apiBaseUrlFromEnv.isNotEmpty) {
      return Uri.parse(_apiBaseUrlFromEnv).host;
    }
    if (devLanHost.isNotEmpty) return devLanHost;
    // Physical device on the same Wi-Fi. Override with:
    // flutter run --dart-define=DEV_LAN_HOST=10.0.2.2  (Android emulator)
    // USB debugging: adb reverse tcp:8000 tcp:8000 and DEV_LAN_HOST=127.0.0.1
    return '192.168.100.43';
  }

  static String get apiBaseUrl {
    if (_apiBaseUrlFromEnv.isNotEmpty) return _apiBaseUrlFromEnv;
    return 'http://$apiHost:$apiPort/api/v1';
  }

  static String get apiOrigin {
    if (_apiBaseUrlFromEnv.isNotEmpty) {
      return Uri.parse(_apiBaseUrlFromEnv).origin;
    }
    return 'http://$apiHost:$apiPort';
  }

  static const String appScheme = 'mzlogistics';

  static String get storageBaseUrl {
    if (_storageBaseUrlFromEnv.isNotEmpty) return _storageBaseUrlFromEnv;
    return 'http://$apiHost:$apiPort/storage';
  }

  static const Duration connectTimeout = Duration(seconds: 12);
  static const Duration receiveTimeout = Duration(seconds: 20);
  static const Duration bootstrapTimeout = Duration(seconds: 8);

  static const String tokenKey = 'mz_customer_token';
  static const String localeKey = 'mz_customer_locale';

  static const String demoEmail = 'customer@gulfmaterials.om';
  static const String demoPassword = 'Password123!';

  static const double mapDefaultLat = 23.5880;
  static const double mapDefaultLng = 58.3829;
  static const double mapCountryZoom = 7;
  static const double mapPlaceZoom = 15;

  static const double desktopBreakpoint = 1024;
  static const double tabletBreakpoint = 768;
  static const double wideBreakpoint = 1440;

  static const List<String> supportedLocales = ['en', 'ar'];
}
