import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mz_logistics_customer_app/core/i18n/i18n_controller.dart';
import 'package:mz_logistics_customer_app/features/home/data/dashboard_model.dart';
import 'package:mz_logistics_customer_app/features/home/presentation/home_providers.dart';
import 'package:mz_logistics_customer_app/features/home/presentation/home_screen.dart';
import 'package:mz_logistics_customer_app/features/shipments/data/shipment_model.dart';
import 'package:mz_logistics_customer_app/features/shipments/presentation/shipment_providers.dart';
import 'package:mz_logistics_customer_app/shared/models/pagination_meta.dart';

void main() {
  testWidgets('home board lays out on a phone in Arabic', (tester) async {
    await _pumpHome(tester, const Size(360, 1400), _arabic, textScale: 1.3);
    expect(find.text('تحتاج إلى شحن بضاعة؟'), findsOneWidget);
    expect(find.text('عروض بانتظار القرار'), findsOneWidget);
    expect(find.text('طلب شحن جديد'), findsWidgets);
    expect(find.text('12 من 20'), findsOneWidget);
    expect(find.byKey(const Key('home-freight-truck')), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('home board lays out on a wide window in English', (
    tester,
  ) async {
    await _pumpHome(tester, const Size(1280, 900), _english);
    expect(find.text('Need to move cargo?'), findsOneWidget);
    expect(find.text('Pending quotations'), findsOneWidget);
    expect(find.text('12 of 20'), findsOneWidget);
    expect(find.text('4 of 11'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

const _summary = DashboardSummary(
  shipmentsOpen: 12,
  shipmentsTotal: 20,
  quotationsPending: 3,
  jobsActive: 4,
  jobsCompleted: 7,
  tripsActive: 6,
  tripsInTransit: 2,
  paymentsCompletedAmount: 1240,
  invoicesCount: 8,
);

const _arabic = I18nBundle(
  locale: Locale('ar'),
  strings: {
    'home.snapshot': 'لمحة سريعة',
    'home.ofTotal': '{current} من {total}',
    'home.heroTitle': 'تحتاج إلى شحن بضاعة؟',
    'home.heroBody': 'أنشئ طلباً وقارن عروض الأسعار من مزودي الخدمة.',
    'home.newShipment': 'طلب شحن جديد',
    'home.shipmentsOpen': 'طلبات مفتوحة',
    'home.quotationsPending': 'عروض بانتظار القرار',
    'home.jobsActive': 'مهام نشطة',
    'home.tripsInTransit': 'رحلات في الطريق',
    'home.paymentsCompleted': 'المبالغ المدفوعة',
    'home.invoices': 'الفواتير',
    'home.quickActions': 'اختصارات',
    'nav.shipmentsShort': 'الشحنات',
    'nav.jobs': 'المهام',
    'nav.invoices': 'الفواتير',
    'nav.payments': 'المدفوعات',
    'home.recentShipments': 'أحدث طلبات الشحن',
    'common.viewAll': 'عرض الكل',
    'home.noShipments': 'لا توجد طلبات شحن بعد',
    'home.emptyHint': 'أنشئ طلب شحن لتبدأ باستلام عروض الأسعار.',
  },
);

const _english = I18nBundle(
  locale: Locale('en'),
  strings: {
    'home.snapshot': 'At a glance',
    'home.ofTotal': '{current} of {total}',
    'home.heroTitle': 'Need to move cargo?',
    'home.heroBody':
        'Create a request and compare quotations from service providers.',
    'home.newShipment': 'New shipment request',
    'home.shipmentsOpen': 'Open requests',
    'home.quotationsPending': 'Pending quotations',
    'home.jobsActive': 'Active jobs',
    'home.tripsInTransit': 'Trips in transit',
    'home.paymentsCompleted': 'Paid amount',
    'home.invoices': 'Invoices',
    'home.quickActions': 'Shortcuts',
    'nav.shipmentsShort': 'Shipments',
    'nav.jobs': 'Jobs',
    'nav.invoices': 'Invoices',
    'nav.payments': 'Payments',
    'home.recentShipments': 'Recent shipment requests',
    'common.viewAll': 'View all',
    'home.noShipments': 'No shipment requests yet',
    'home.emptyHint':
        'Create a shipment request to start receiving quotations.',
  },
);

class _FixedI18n extends I18nController {
  _FixedI18n(this.bundle);

  final I18nBundle bundle;

  @override
  Future<I18nBundle> build() async => bundle;
}

Future<void> _pumpHome(
  WidgetTester tester,
  Size size,
  I18nBundle bundle, {
  double textScale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/shipments/new',
        builder: (context, state) => const SizedBox(),
      ),
      GoRoute(
        path: '/shipments',
        builder: (context, state) => const SizedBox(),
      ),
      GoRoute(path: '/jobs', builder: (context, state) => const SizedBox()),
      GoRoute(path: '/invoices', builder: (context, state) => const SizedBox()),
      GoRoute(path: '/payments', builder: (context, state) => const SizedBox()),
      GoRoute(path: '/billing', builder: (context, state) => const SizedBox()),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        i18nControllerProvider.overrideWith(() => _FixedI18n(bundle)),
        dashboardProvider.overrideWith((ref) async => _summary),
        shipmentsProvider.overrideWith(
          (ref) async => const PagedResult<ShipmentRequest>(
            items: [],
            meta: PaginationMeta(),
          ),
        ),
      ],
      child: MaterialApp.router(
        locale: bundle.locale,
        supportedLocales: const [Locale('en'), Locale('ar')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(textScale)),
            child: child ?? const SizedBox.shrink(),
          );
        },
        routerConfig: router,
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 1000));
}
