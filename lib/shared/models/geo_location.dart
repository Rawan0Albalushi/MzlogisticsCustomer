class GeoLocation {
  const GeoLocation({
    required this.address,
    required this.city,
    required this.lat,
    required this.lng,
    this.placeId,
    this.governorate = '',
    this.wilayat = '',
  });

  final String address;
  final String city;
  final String governorate;
  final String wilayat;
  final double lat;
  final double lng;
  final String? placeId;

  bool get hasCoordinates => lat.abs() <= 90 && lng.abs() <= 180;

  String get areaLabel {
    final parts = <String>[
      if (wilayat.trim().isNotEmpty) wilayat.trim(),
      if (governorate.trim().isNotEmpty) governorate.trim(),
    ];
    if (parts.isEmpty) return city;
    return parts.join('، ');
  }

  GeoLocation copyWith({
    String? address,
    String? city,
    String? governorate,
    String? wilayat,
    double? lat,
    double? lng,
    String? placeId,
  }) {
    return GeoLocation(
      address: address ?? this.address,
      city: city ?? this.city,
      governorate: governorate ?? this.governorate,
      wilayat: wilayat ?? this.wilayat,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      placeId: placeId ?? this.placeId,
    );
  }
}
