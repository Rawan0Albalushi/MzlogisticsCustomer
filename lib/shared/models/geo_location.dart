class GeoLocation {
  const GeoLocation({
    required this.address,
    required this.city,
    required this.lat,
    required this.lng,
    this.placeId,
  });

  final String address;
  final String city;
  final double lat;
  final double lng;
  final String? placeId;

  bool get hasCoordinates => lat.abs() <= 90 && lng.abs() <= 180;

  GeoLocation copyWith({
    String? address,
    String? city,
    double? lat,
    double? lng,
    String? placeId,
  }) {
    return GeoLocation(
      address: address ?? this.address,
      city: city ?? this.city,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      placeId: placeId ?? this.placeId,
    );
  }
}
