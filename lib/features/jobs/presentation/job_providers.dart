import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/pagination_meta.dart';
import '../../trips/data/customer_trip_progress.dart';
import '../data/job_model.dart';
import '../data/job_repository.dart';

const _activeJobRefresh = Duration(seconds: 15);

final jobsProvider = FutureProvider.autoDispose<PagedResult<TransportJob>>((ref) {
  return ref.watch(jobRepositoryProvider).list();
});

final jobDetailProvider =
    FutureProvider.autoDispose.family<TransportJob, int>((ref, id) async {
  final job = await ref.watch(jobRepositoryProvider).getById(id);
  final active = job.status == 'in_progress' ||
      job.status == 'pending_dispatch' ||
      job.trips.any((trip) => CustomerTripProgress.isActive(trip.status));
  if (active) {
    final timer = Timer(_activeJobRefresh, ref.invalidateSelf);
    ref.onDispose(timer.cancel);
  }
  return job;
});
