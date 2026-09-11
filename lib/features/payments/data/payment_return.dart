import '../../../core/constants/app_constants.dart';

class PaymentReturn {
  const PaymentReturn._();

  static bool isApiCallback(Uri uri) {
    final path = uri.path;
    return path.contains('/api/v1/payments/success') || path.contains('/api/v1/payments/cancel');
  }

  static bool isAppReturn(Uri uri) {
    if (uri.scheme == AppConstants.appScheme) {
      return true;
    }
    if (uri.path.contains('/api/')) {
      return false;
    }
    return uri.path.endsWith('/payment/success') || uri.path.endsWith('/payment/cancel');
  }

  static bool isCancel(Uri uri) {
    return uri.path.contains('cancel');
  }
}
