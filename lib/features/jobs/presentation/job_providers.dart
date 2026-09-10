import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/pagination_meta.dart';
import '../data/job_model.dart';
import '../data/job_repository.dart';

final jobsProvider = FutureProvider.autoDispose<PagedResult<TransportJob>>((ref) {
  return ref.watch(jobRepositoryProvider).list();
});

final jobDetailProvider =
    FutureProvider.autoDispose.family<TransportJob, int>((ref, id) {
  return ref.watch(jobRepositoryProvider).getById(id);
});
