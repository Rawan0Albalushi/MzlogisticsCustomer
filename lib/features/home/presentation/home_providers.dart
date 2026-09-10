import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/dashboard_model.dart';
import '../data/dashboard_repository.dart';

final dashboardProvider = FutureProvider.autoDispose<DashboardSummary>((ref) {
  return ref.watch(dashboardRepositoryProvider).fetch();
});
