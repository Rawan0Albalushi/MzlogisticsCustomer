import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/providers.dart';
import '../../../core/utils/json_utils.dart';
import '../../../shared/models/geo_location.dart';
import 'oman_geo.dart';
import 'place_suggestion.dart';

class PlacesRepository {
  PlacesRepository(this._api);

  final ApiClient _api;

  Future<List<PlaceSuggestion>> autocomplete(String query) async {
    final envelope = await _api.get('/places/autocomplete', query: {'query': query});
    return asList(asMap(envelope.data)['suggestions'])
        .whereType<Map>()
        .map((item) => PlaceSuggestion.fromJson(asMap(item)))
        .where((item) => item.placeId.isNotEmpty)
        .toList();
  }

  Future<GeoLocation> details(String placeId, {String language = 'ar'}) async {
    final envelope = await _api.get('/places/details', query: {'place_id': placeId});
    var location = applyOmanDivisions(geoLocationFromPlaceJson(envelope.map));
    if (location.governorate.isNotEmpty && location.wilayat.isNotEmpty) {
      return location;
    }
    final osm = await _nominatimReverse(location.lat, location.lng, language);
    if (osm == null) return location;
    return applyOmanDivisions(
      location.copyWith(
        governorate: osm.governorate.isNotEmpty ? osm.governorate : location.governorate,
        wilayat: osm.wilayat.isNotEmpty ? osm.wilayat : location.wilayat,
        city: osm.city.isNotEmpty ? osm.city : location.city,
      ),
    );
  }

  Future<GeoLocation?> reverse(double lat, double lng, {String language = 'ar'}) async {
    GeoLocation? location;
    try {
      final envelope = await _api.get('/places/reverse', query: {'lat': lat, 'lng': lng});
      if (envelope.map.isNotEmpty) {
        location = applyOmanDivisions(
          geoLocationFromPlaceJson(envelope.map).copyWith(lat: lat, lng: lng),
        );
      }
    } catch (_) {
      location = null;
    }

    if (location != null && location.governorate.isNotEmpty && location.wilayat.isNotEmpty) {
      return location;
    }

    final osm = await _nominatimReverse(lat, lng, language);
    if (osm == null) return location;
    if (location == null) return osm;

    return applyOmanDivisions(
      location.copyWith(
        governorate: osm.governorate.isNotEmpty ? osm.governorate : location.governorate,
        wilayat: osm.wilayat.isNotEmpty ? osm.wilayat : location.wilayat,
        city: osm.city.isNotEmpty ? osm.city : location.city,
      ),
    );
  }

  Future<GeoLocation?> _nominatimReverse(double lat, double lng, String language) async {
    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
        ),
      );
      final response = await dio.get<dynamic>(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'lat': lat,
          'lon': lng,
          'format': 'jsonv2',
          'addressdetails': 1,
          'zoom': 14,
        },
        options: Options(
          headers: {
            'User-Agent': 'MZLogisticsCustomer/1.0',
            'Accept-Language': language,
          },
        ),
      );
      return geoLocationFromNominatim(
        asMap(response.data),
        lat: lat,
        lng: lng,
        language: language,
      );
    } catch (_) {
      return null;
    }
  }
}

final placesRepositoryProvider = Provider<PlacesRepository>((ref) {
  return PlacesRepository(ref.watch(apiClientProvider));
});
