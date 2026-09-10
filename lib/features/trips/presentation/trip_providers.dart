import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/trip_model.dart';
import '../data/trip_repository.dart';

final tripDetailProvider = FutureProvider.autoDispose.family<Trip, int>((ref, id) {
  return ref.watch(tripRepositoryProvider).getById(id);
});
