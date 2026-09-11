import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

/// Chrome mobile UA without the `; wv` marker. Thawani can render a blank page
/// when it detects an embedded Android WebView user agent.
const String _chromeMobileUserAgent =
    'Mozilla/5.0 (Linux; Android 13; Mobile) AppleWebKit/537.36 '
    '(KHTML, like Gecko) Chrome/120.0.6099.230 Mobile Safari/537.36';

Future<void> configureCheckoutWebView(WebViewController controller) async {
  await controller.setUserAgent(_chromeMobileUserAgent);
  final platform = controller.platform;
  if (platform is AndroidWebViewController) {
    await platform.setMixedContentMode(MixedContentMode.compatibilityMode);
  }
}

Widget buildCheckoutWebView(WebViewController controller) {
  if (defaultTargetPlatform == TargetPlatform.android) {
    return WebViewWidget.fromPlatformCreationParams(
      params: AndroidWebViewWidgetCreationParams(
        controller: controller.platform,
        displayWithHybridComposition: true,
      ),
    );
  }
  return WebViewWidget(controller: controller);
}
