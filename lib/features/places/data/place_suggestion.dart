import '../../../core/utils/json_utils.dart';
import '../../../shared/models/geo_location.dart';

class PlaceSuggestion {
  const PlaceSuggestion({
    required this.placeId,
    required this.description,
    this.mainText,
    this.secondaryText,
  });

  final String placeId;
  final String description;
  final String? mainText;
  final String? secondaryText;

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    return PlaceSuggestion(
      placeId: asString(json['place_id']) ?? '',
      description: asString(json['description']) ?? '',
      mainText: asString(json['main_text']),
      secondaryText: asString(json['secondary_text']),
    );
  }
}

GeoLocation geoLocationFromPlaceJson(Map<String, dynamic> json) {
  return GeoLocation(
    address: asString(json['address']) ?? '',
    city: asString(json['city']) ?? '',
    lat: asDouble(json['lat']) ?? 0,
    lng: asDouble(json['lng']) ?? 0,
    placeId: asString(json['place_id']),
  );
}
