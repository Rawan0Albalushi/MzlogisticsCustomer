import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/invoices/presentation/invoices_screen.dart';
import '../../features/jobs/presentation/job_detail_screen.dart';
import '../../features/jobs/presentation/jobs_list_screen.dart';
import '../../features/notifications/presentation/notification_providers.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/payments/presentation/billing_screen.dart';
import '../../features/payments/presentation/payment_checkout_screen.dart';
import '../../features/payments/presentation/payment_result_screens.dart';
import '../../features/payments/presentation/payments_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/quotations/presentation/quotations_screen.dart';
import '../../features/shipments/presentation/create_shipment_screen.dart';
import '../../features/shipments/presentation/shipment_detail_screen.dart';
import '../../features/shipments/presentation/shipments_list_screen.dart';
import '../../features/trips/presentation/pod_screen.dart';
import '../../features/trips/presentation/trip_detail_screen.dart';
import '../../shared/widgets/responsive_scaffold.dart';
import '../i18n/i18n_controller.dart';

class RouterRefresh extends ChangeNotifier {
  void ping() => notifyListeners();
}

final routerRefreshProvider = Provider<RouterRefresh>((ref) {
  final refresh = RouterRefresh();
  ref.listen(authControllerProvider, (_, _) => refresh.ping());
  ref.onDispose(refresh.dispose);
  return refresh;
});

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ref.watch(routerRefreshProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final location = state.matchedLocation;
      const authRoutes = {'/login', '/register', '/forgot-password'};
      if (auth.status == AuthStatus.unknown) {
        if (location.startsWith('/payment')) return null;
        return location == '/splash' ? null : '/splash';
      }
      if (!auth.isAuthenticated) {
        return authRoutes.contains(location) ? null : '/login';
      }
      if (authRoutes.contains(location) || location == '/splash') {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/home', builder: (context, state) => const HomeScreen())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/shipments', builder: (context, state) => const ShipmentsListScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/jobs', builder: (context, state) => const JobsListScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/invoices', builder: (context, state) => const InvoicesScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/payments', builder: (context, state) => const PaymentsScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/billing', builder: (context, state) => const BillingScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen())],
          ),
        ],
      ),
      GoRoute(path: '/shipments/new', builder: (context, state) => const CreateShipmentScreen()),
      GoRoute(
        path: '/shipments/:id',
        builder: (context, state) => ShipmentDetailScreen(
          shipmentId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/shipments/:id/quotations',
        builder: (context, state) => QuotationsScreen(
          shipmentId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/quotations/:id',
        builder: (context, state) => QuotationDetailScreen(
          quotationId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/jobs/:id',
        builder: (context, state) => JobDetailScreen(
          jobId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/trips/:id',
        builder: (context, state) => TripDetailScreen(
          tripId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/trips/:id/tracking',
        builder: (context, state) => TripTrackingScreen(
          tripId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/trips/:id/pod',
        builder: (context, state) => PodScreen(
          tripId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/payments/checkout/:id',
        builder: (context, state) => PaymentCheckoutScreen(
          paymentId: int.parse(state.pathParameters['id']!),
          paymentLink: state.extra is String ? state.extra as String : null,
        ),
      ),
      GoRoute(
        path: '/payment/success',
        builder: (context, state) => PaymentSuccessScreen(
          paymentId: int.tryParse(state.uri.queryParameters['payment_id'] ?? ''),
          jobId: int.tryParse(state.uri.queryParameters['job_id'] ?? ''),
          success: state.uri.queryParameters['success'] != '0',
        ),
      ),
      GoRoute(
        path: '/payment/cancel',
        builder: (context, state) => PaymentCancelScreen(
          paymentId: int.tryParse(state.uri.queryParameters['payment_id'] ?? ''),
        ),
      ),
    ],
  );
});

class _AppShell extends ConsumerWidget {
  const _AppShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = ref.i18n;
    final user = ref.watch(authControllerProvider).user;
    final unread = ref.watch(notificationsProvider).maybeWhen(
          data: (page) => page.items.where((item) => item.isUnread).length,
          orElse: () => 0,
        );
    return ResponsiveScaffold(
      navigationShell: navigationShell,
      i18n: i18n,
      userName: user?.name ?? '',
      unreadCount: unread,
    );
  }
}
