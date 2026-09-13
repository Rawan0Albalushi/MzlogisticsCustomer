import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/providers.dart';
import '../../../core/utils/json_utils.dart';
import '../../../shared/models/geo_location.dart';
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

  Future<GeoLocation> details(String placeId) async {
    final envelope = await _api.get('/places/details', query: {'place_id': placeId});
    return geoLocationFromPlaceJson(envelope.map);
  }

  Future<GeoLocation?> reverse(double lat, double lng) async {
    final envelope = await _api.get('/places/reverse', query: {'lat': lat, 'lng': lng});
    if (envelope.map.isEmpty) return null;
    final location = geoLocationFromPlaceJson(envelope.map);
    if (!location.hasCoordinates || location.address.isEmpty) {
      return location.copyWith(address: location.address, lat: lat, lng: lng);
    }
    return location;
  }
}

final placesRepositoryProvider = Provider<PlacesRepository>((ref) {
  return PlacesRepository(ref.watch(apiClientProvider));
});
