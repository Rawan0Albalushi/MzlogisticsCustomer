import '../../core/utils/json_utils.dart';

class PaginationMeta {
  const PaginationMeta({
    this.currentPage = 1,
    this.lastPage = 1,
    this.perPage = 15,
    this.total = 0,
  });

  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  bool get hasMore => currentPage < lastPage;

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    final nested = json['data'] is Map ? asMap(json['data']) : json;
    return PaginationMeta(
      currentPage: asInt(json['current_page'] ?? nested['current_page']) ?? 1,
      lastPage: asInt(json['last_page'] ?? nested['last_page']) ?? 1,
      perPage: asInt(json['per_page'] ?? nested['per_page']) ?? 15,
      total: asInt(json['total'] ?? nested['total']) ?? 0,
    );
  }
}

class PagedResult<T> {
  const PagedResult({required this.items, required this.meta});

  final List<T> items;
  final PaginationMeta meta;
}
