import '../utils/json_utils.dart';

class ApiEnvelope {
  const ApiEnvelope({
    required this.success,
    required this.message,
    this.data,
    this.meta = const {},
  });

  final bool success;
  final String message;
  final dynamic data;
  final Map<String, dynamic> meta;

  factory ApiEnvelope.fromJson(dynamic raw) {
    final map = asMap(raw);
    return ApiEnvelope(
      success: asBool(map['success'], fallback: true),
      message: asString(map['message']) ?? '',
      data: map['data'],
      meta: asMap(map['meta']),
    );
  }

  List<dynamic> get list {
    if (data is List) return data as List<dynamic>;
    final nested = asMap(data);
    if (nested['data'] is List) return nested['data'] as List<dynamic>;
    return const [];
  }

  Map<String, dynamic> get map => asMap(data);
}
