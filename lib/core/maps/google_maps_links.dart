import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class GoogleMapsLinks {
  GoogleMapsLinks._();

  static Uri view({required double lat, required double lng}) {
    return Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
  }

  static Uri directions({required double lat, required double lng}) {
    return Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
    );
  }

  static Future<bool> open({
    required double lat,
    required double lng,
    bool navigate = false,
  }) {
    final uri = navigate ? directions(lat: lat, lng: lng) : view(lat: lat, lng: lng);
    return launchUrl(
      uri,
      mode: kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication,
    );
  }
}
