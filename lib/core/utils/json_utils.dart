import 'dart:convert';

int? asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double? asDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

bool asBool(dynamic value, {bool fallback = false}) {
  if (value == null) return fallback;
  if (value is bool) return value;
  if (value is num) return value != 0;
  final raw = value.toString().toLowerCase();
  return raw == 'true' || raw == '1' || raw == 'yes';
}

String? asString(dynamic value) {
  if (value == null) return null;
  final raw = value.toString();
  return raw.isEmpty || raw == 'null' ? null : raw;
}

DateTime? asDateTime(dynamic value) {
  final raw = asString(value);
  if (raw == null) return null;
  return DateTime.tryParse(raw);
}

Map<String, dynamic> asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.map((key, item) => MapEntry('$key', item));
  return <String, dynamic>{};
}

List<dynamic> asList(dynamic value) {
  if (value is List) return value;
  return const [];
}

List<String> asStringList(dynamic value) {
  if (value is List) {
    return value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty && item != 'null')
        .toList();
  }
  if (value is Map) {
    return asStringList(value.values.toList());
  }
  if (value is String && value.trim().isNotEmpty) {
    final raw = value.trim();
    if (raw.startsWith('[') || raw.startsWith('{')) {
      try {
        return asStringList(jsonDecode(raw));
      } catch (_) {}
    }
    return [raw];
  }
  return const [];
}
