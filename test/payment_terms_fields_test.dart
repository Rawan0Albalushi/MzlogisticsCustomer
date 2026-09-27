import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mz_logistics_customer_app/core/i18n/i18n_controller.dart';
import 'package:mz_logistics_customer_app/features/payments/presentation/widgets/payment_terms_fields.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ar');
  });

  const i18n = I18nBundle(
    locale: Locale('ar'),
    strings: {
      'paymentContract.unit': 'وحدة الفوترة',
      'paymentContract.unitJob': 'كلي',
      'paymentContract.unitJobHint':
          'فاتورة واحدة بكامل مبلغ العرض بعد اكتمال المهمة.',
      'paymentContract.unitTrip': 'جزئي بعد كل شحنة',
      'paymentContract.unitTripHint': 'فاتورة مستقلة بعد تسليم كل رحلة.',
      'paymentContract.dueDays': 'الاستحقاق',
      'paymentContract.dueImmediate': 'مستحق فور التسليم',
      'paymentContract.dueOnDate': 'تحديد تاريخ',
      'paymentContract.pickDueDate': 'اختر تاريخ الاستحقاق',
    },
  );

  Future<void> pumpFields(
    WidgetTester tester, {
    required String unit,
    required int dueDays,
    required ValueChanged<String> onUnitChanged,
    required ValueChanged<int> onDueDaysChanged,
  }) {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    return tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: PaymentTermsFields(
              i18n: i18n,
              trigger: 'on_delivery',
              unit: unit,
              dueDays: dueDays,
              onTriggerChanged: (_) {},
              onUnitChanged: onUnitChanged,
              onDueDaysChanged: onDueDaysChanged,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('shows billing groups without overflow on a phone width', (
    tester,
  ) async {
    await pumpFields(
      tester,
      unit: 'job',
      dueDays: 0,
      onUnitChanged: (_) {},
      onDueDaysChanged: (_) {},
    );

    expect(find.text('وحدة الفوترة'), findsOneWidget);
    expect(find.text('كلي'), findsOneWidget);
    expect(find.text('جزئي بعد كل شحنة'), findsOneWidget);
    expect(find.text('الاستحقاق'), findsOneWidget);
    expect(find.text('مستحق فور التسليم'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('selects per-shipment billing from the option row', (
    tester,
  ) async {
    String? selected;
    await pumpFields(
      tester,
      unit: 'job',
      dueDays: 0,
      onUnitChanged: (value) => selected = value,
      onDueDaysChanged: (_) {},
    );

    await tester.tap(find.text('جزئي بعد كل شحنة'));
    await tester.pump();
    expect(selected, 'trip');
  });

  testWidgets('clears a specified due date when immediate payment is chosen', (
    tester,
  ) async {
    int? dueDays;
    await pumpFields(
      tester,
      unit: 'job',
      dueDays: 7,
      onUnitChanged: (_) {},
      onDueDaysChanged: (value) => dueDays = value,
    );

    expect(find.text('تحديد تاريخ'), findsOneWidget);
    await tester.tap(find.text('مستحق فور التسليم'));
    await tester.pump();
    expect(dueDays, 0);
  });
}
