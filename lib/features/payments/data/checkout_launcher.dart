import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

Future<bool> openThawaniCheckout(String paymentLink) {
  return launchUrl(
    Uri.parse(paymentLink),
    mode: kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication,
    webOnlyWindowName: kIsWeb ? '_self' : '_blank',
  );
}
