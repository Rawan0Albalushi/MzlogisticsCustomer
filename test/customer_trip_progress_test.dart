import 'package:flutter_test/flutter_test.dart';
import 'package:mz_logistics_customer_app/features/trips/data/customer_trip_progress.dart';
import 'package:mz_logistics_customer_app/features/trips/data/trip_model.dart';

void main() {
  group('CustomerTripProgress.stageOf', () {
    test('keeps only the four customer stages', () {
      expect(CustomerTripProgress.stages, [
        'assigned',
        'loaded',
        'in_transit',
        'delivered',
      ]);
    });

    test('maps driver statuses onto the basic customer stages', () {
      expect(CustomerTripProgress.stageOf('unassigned'), 'assigned');
      expect(CustomerTripProgress.stageOf('assigned'), 'assigned');
      expect(CustomerTripProgress.stageOf('arrived_at_pickup'), 'assigned');
      expect(CustomerTripProgress.stageOf('loaded'), 'loaded');
      expect(CustomerTripProgress.stageOf('in_transit'), 'in_transit');
      expect(CustomerTripProgress.stageOf('arrived'), 'in_transit');
      expect(CustomerTripProgress.stageOf('delivered'), 'delivered');
      expect(CustomerTripProgress.stageOf('completed'), 'delivered');
      expect(CustomerTripProgress.stageOf('cancelled'), 'cancelled');
    });

    test('treats in-progress driver statuses as active', () {
      expect(CustomerTripProgress.isActive('assigned'), isTrue);
      expect(CustomerTripProgress.isActive('arrived_at_pickup'), isTrue);
      expect(CustomerTripProgress.isActive('loaded'), isTrue);
      expect(CustomerTripProgress.isActive('in_transit'), isTrue);
      expect(CustomerTripProgress.isActive('arrived'), isTrue);
      expect(CustomerTripProgress.isActive('delivered'), isFalse);
      expect(CustomerTripProgress.isActive('completed'), isFalse);
      expect(CustomerTripProgress.isActive('cancelled'), isFalse);
    });
  });

  test('uses delivery timestamps for the delivered stage', () {
    final trip = Trip(
      id: 12,
      deliveredAt: DateTime.utc(2026, 9, 16, 8),
      completedAt: DateTime.utc(2026, 9, 16, 9),
    );

    expect(
      CustomerTripProgress.timestampFor(trip, CustomerTripProgress.delivered),
      DateTime.utc(2026, 9, 16, 8),
    );
  });
}
