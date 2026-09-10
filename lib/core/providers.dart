import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api/api_client.dart';
import 'i18n/i18n_controller.dart';
import 'storage/token_storage.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    tokenStorage: ref.watch(tokenStorageProvider),
    localeReader: () {
      return ref.read(i18nControllerProvider).maybeWhen(
            data: (bundle) => bundle.locale.languageCode,
            orElse: () => 'en',
          );
    },
    onUnauthorized: () {
      ref.read(unauthorizedTickProvider.notifier).state++;
    },
  );
});
