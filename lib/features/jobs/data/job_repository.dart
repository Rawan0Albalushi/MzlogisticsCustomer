import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/providers.dart';
import '../../../core/utils/json_utils.dart';
import '../../../shared/models/pagination_meta.dart';
import 'job_model.dart';

class JobRepository {
  JobRepository(this._api);

  final ApiClient _api;

  Future<PagedResult<TransportJob>> list({int page = 1, String? status}) async {
    final envelope = await _api.get('/jobs', query: {
      'page': page,
      'status': ?status,
    });
    return PagedResult(
      items: envelope.list
          .whereType<Map>()
          .map((item) => TransportJob.fromJson(asMap(item)))
          .toList(),
      meta: PaginationMeta.fromJson(envelope.meta.isEmpty ? envelope.map : envelope.meta),
    );
  }

  Future<TransportJob> getById(int id) async {
    final envelope = await _api.get('/jobs/$id');
    return TransportJob.fromJson(envelope.map);
  }
}

final jobRepositoryProvider = Provider<JobRepository>((ref) {
  return JobRepository(ref.watch(apiClientProvider));
});
