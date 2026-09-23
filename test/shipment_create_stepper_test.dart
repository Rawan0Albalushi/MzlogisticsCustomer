import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mz_logistics_customer_app/features/shipments/presentation/widgets/shipment_create_stepper.dart';

void main() {
  const steps = [
    ShipmentCreateStep(label: 'Cargo', icon: Icons.inventory_2_outlined),
    ShipmentCreateStep(label: 'Route', icon: Icons.route_rounded),
    ShipmentCreateStep(label: 'Date', icon: Icons.event_outlined),
  ];

  Future<void> pumpStepper(
    WidgetTester tester, {
    required int current,
    ValueChanged<int>? onSelect,
    bool Function(int index)? canSelect,
    TextDirection direction = TextDirection.ltr,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: direction,
          child: Scaffold(
            body: ShipmentCreateStepper(
              steps: steps,
              current: current,
              progressLabel: 'Step ${current + 1} of 3',
              onSelect: onSelect,
              canSelect: canSelect,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('shows every stage label', (tester) async {
    await pumpStepper(tester, current: 0);
    expect(find.text('Cargo'), findsOneWidget);
    expect(find.text('Route'), findsOneWidget);
    expect(find.text('Date'), findsOneWidget);
  });

  testWidgets('returns to a completed stage and ignores a later one', (
    tester,
  ) async {
    final tapped = <int>[];
    await pumpStepper(
      tester,
      current: 1,
      onSelect: tapped.add,
      canSelect: (index) => index <= 1,
    );

    await tester.tap(find.text('Cargo'));
    await tester.pump();
    expect(tapped, [0]);

    await tester.tap(find.text('Date'));
    await tester.pump();
    expect(tapped, [0]);
  });

  testWidgets('keeps stage labels visible in Arabic layout', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: SizedBox(
              width: 360,
              child: ShipmentCreateStepper(
                steps: [
                  ShipmentCreateStep(
                    label: 'بيانات البضاعة',
                    icon: Icons.inventory_2_outlined,
                  ),
                  ShipmentCreateStep(
                    label: 'التحميل والتسليم',
                    icon: Icons.route_rounded,
                  ),
                  ShipmentCreateStep(
                    label: 'التاريخ والدفع',
                    icon: Icons.event_outlined,
                  ),
                ],
                current: 1,
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('بيانات البضاعة'), findsOneWidget);
    expect(find.text('التحميل والتسليم'), findsOneWidget);
    expect(find.text('التاريخ والدفع'), findsOneWidget);
  });
}
