import '../../../core/utils/json_utils.dart';
import '../../../shared/models/geo_location.dart';

const _governorateIso = {
  'OM-MA': ('مسقط', 'Muscat'),
  'OM-ZU': ('ظفار', 'Dhofar'),
  'OM-MU': ('مسندم', 'Musandam'),
  'OM-BU': ('البريمي', 'Al Buraimi'),
  'OM-DA': ('الداخلية', 'Ad Dakhiliyah'),
  'OM-WU': ('الوسطى', 'Al Wusta'),
  'OM-ZA': ('الظاهرة', 'Ad Dhahirah'),
  'OM-BS': ('جنوب الباطنة', 'Al Batinah South'),
  'OM-BJ': ('شمال الباطنة', 'Al Batinah North'),
  'OM-BA': ('الباطنة', 'Al Batinah'),
  'OM-SS': ('جنوب الشرقية', 'Ash Sharqiyah South'),
  'OM-SJ': ('شمال الشرقية', 'Ash Sharqiyah North'),
  'OM-SH': ('الشرقية', 'Ash Sharqiyah'),
};

String stripOmanDivisionPrefix(String value) {
  var name = value.trim();
  if (name.isEmpty) return '';
  name = name.replaceFirst(RegExp(r'^(محافظة|ولاية)\s+'), '');
  name = name.replaceFirst(RegExp(r'^(Governorate|Wilayat|Wilaya)(\s+of)?\s+', caseSensitive: false), '');
  name = name.replaceFirst(RegExp(r'\s+(Governorate|Wilayat|Wilaya)\s*$', caseSensitive: false), '');
  return name.trim();
}

bool sameOmanPlaceName(String left, String right) {
  final a = stripOmanDivisionPrefix(left).toLowerCase();
  final b = stripOmanDivisionPrefix(right).toLowerCase();
  return a.isNotEmpty && a == b;
}

GeoLocation applyOmanDivisions(GeoLocation location) {
  var governorate = stripOmanDivisionPrefix(location.governorate);
  var wilayat = stripOmanDivisionPrefix(location.wilayat);

  if (governorate.isEmpty && wilayat.isEmpty) {
    final parts = location.city
        .split(RegExp(r'\s*[،,]\s*'))
        .map(stripOmanDivisionPrefix)
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.length >= 2) {
      wilayat = parts.first;
      governorate = parts.sublist(1).join(', ');
    } else if (parts.length == 1) {
      wilayat = parts.first;
    }
  }

  if (wilayat.isNotEmpty && sameOmanPlaceName(wilayat, governorate)) {
    wilayat = '';
  }

  final city = [
    if (wilayat.isNotEmpty) wilayat,
    if (governorate.isNotEmpty) governorate,
  ].join(', ');

  return location.copyWith(
    governorate: governorate,
    wilayat: wilayat,
    city: city.isNotEmpty ? city : location.city,
  );
}

GeoLocation? geoLocationFromNominatim(
  Map<String, dynamic> json, {
  required double lat,
  required double lng,
  required String language,
}) {
  final address = asMap(json['address']);
  if (address.isEmpty) return null;

  final iso = asString(address['ISO3166-2-lvl4']) ?? asString(address['iso3166-2-lvl4']);
  final arabic = language.toLowerCase().startsWith('ar');
  final isoNames = iso == null ? null : _governorateIso[iso.toUpperCase()];

  final governorate = stripOmanDivisionPrefix(
    asString(address['state']) ??
        asString(address['region']) ??
        (isoNames == null ? '' : (arabic ? isoNames.$1 : isoNames.$2)),
  );

  var wilayat = stripOmanDivisionPrefix(
    asString(address['province']) ??
        asString(address['county']) ??
        asString(address['municipality']) ??
        asString(address['state_district']) ??
        '',
  );

  if (wilayat.isEmpty || sameOmanPlaceName(wilayat, governorate)) {
    wilayat = stripOmanDivisionPrefix(
      asString(address['city']) ??
          asString(address['town']) ??
          asString(address['village']) ??
          asString(address['suburb']) ??
          '',
    );
  }

  if (wilayat.isNotEmpty && sameOmanPlaceName(wilayat, governorate)) {
    wilayat = stripOmanDivisionPrefix(
      asString(address['suburb']) ?? asString(address['city_district']) ?? '',
    );
  }

  if (governorate.isEmpty && wilayat.isEmpty) return null;

  return applyOmanDivisions(
    GeoLocation(
      address: '',
      city: '',
      governorate: governorate,
      wilayat: wilayat,
      lat: lat,
      lng: lng,
    ),
  );
}
