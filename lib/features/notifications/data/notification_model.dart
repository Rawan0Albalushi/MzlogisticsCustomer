import '../../../core/utils/json_utils.dart';

class AppNotification {
  const AppNotification({
    required this.id,
    this.type,
    this.title,
    this.body,
    this.readAt,
    this.createdAt,
    this.data = const {},
  });

  final String id;
  final String? type;
  final String? title;
  final String? body;
  final DateTime? readAt;
  final DateTime? createdAt;
  final Map<String, dynamic> data;

  bool get isUnread => readAt == null;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final payload = asMap(json['data']);
    return AppNotification(
      id: asString(json['id']) ?? '',
      type: asString(json['type']),
      title: asString(payload['title'] ?? json['title']),
      body: asString(payload['body'] ?? payload['message'] ?? json['body']),
      readAt: asDateTime(json['read_at']),
      createdAt: asDateTime(json['created_at']),
      data: payload,
    );
  }
}
