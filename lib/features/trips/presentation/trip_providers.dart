import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/customer_trip_progress.dart';
import '../data/trip_model.dart';
import '../data/trip_repository.dart';

const _activeTripRefresh = Duration(seconds: 15);

final tripDetailProvider = FutureProvider.autoDispose.family<Trip, int>((
  ref,
  id,
) async {
  final trip = await ref.watch(tripRepositoryProvider).getById(id);
  if (CustomerTripProgress.isActive(trip.status)) {
    final timer = Timer(_activeTripRefresh, ref.invalidateSelf);
    ref.onDispose(timer.cancel);
  }
  return trip;
});
