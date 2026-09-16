import 'trip_model.dart';

/// Customer-facing trip stages. Driver statuses collapse into these four.
class CustomerTripProgress {
  CustomerTripProgress._();

  static const assigned = 'assigned';
  static const loaded = 'loaded';
  static const inTransit = 'in_transit';
  static const delivered = 'delivered';
  static const cancelled = 'cancelled';

  static const List<String> stages = [
    assigned,
    loaded,
    inTransit,
    delivered,
  ];

  static String stageOf(String? status) {
    return switch (status) {
      'loaded' => loaded,
      'in_transit' || 'arrived' => inTransit,
      'delivered' || 'completed' => delivered,
      'cancelled' => cancelled,
      _ => assigned,
    };
  }

  static bool isFailed(String? status) => status == cancelled;

  static bool isActive(String? status) {
    if (status == null || status.isEmpty) return false;
    if (isFailed(status)) return false;
    return stageOf(status) != delivered;
  }

  static int indexOf(String? status) {
    final index = stages.indexOf(stageOf(status));
    return index < 0 ? 0 : index;
  }

  static DateTime? timestampFor(Trip trip, String stage) {
    return switch (stage) {
      assigned => trip.assignedAt,
      loaded => trip.loadedAt,
      inTransit => trip.inTransitAt,
      delivered => trip.deliveredAt ?? trip.completedAt,
      _ => null,
    };
  }
}
