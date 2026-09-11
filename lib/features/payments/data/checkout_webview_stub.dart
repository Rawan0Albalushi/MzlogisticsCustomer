import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

Future<void> configureCheckoutWebView(WebViewController controller) async {}

Widget buildCheckoutWebView(WebViewController controller) {
  return WebViewWidget(controller: controller);
}
