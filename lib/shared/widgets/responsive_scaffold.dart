import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/i18n/i18n_controller.dart';
import '../../core/router/section_paths.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/breakpoints.dart';
import 'app_header.dart';
import 'brand_mark.dart';

class ShellDestination {
  const ShellDestination({
    required this.location,
    required this.labelKey,
    required this.icon,
    required this.selectedIcon,
    this.shortLabelKey,
    this.mobile = true,
  });

  final String location;
  final String labelKey;
  final String? shortLabelKey;
  final IconData icon;
  final IconData selectedIcon;
  final bool mobile;

  String label(I18nBundle i18n, {bool compact = false}) {
    if (compact && shortLabelKey != null) return i18n.t(shortLabelKey!);
    return i18n.t(labelKey);
  }
}

const shellDestinations = [
  ShellDestination(
    location: '/home',
    labelKey: 'nav.home',
    icon: Icons.space_dashboard_outlined,
    selectedIcon: Icons.space_dashboard,
  ),
  ShellDestination(
    location: '/shipments',
    labelKey: 'nav.shipments',
    shortLabelKey: 'nav.shipmentsShort',
    icon: Icons.inventory_2_outlined,
    selectedIcon: Icons.inventory_2,
  ),
  ShellDestination(
    location: '/jobs',
    labelKey: 'nav.jobs',
    icon: Icons.assignment_outlined,
    selectedIcon: Icons.assignment,
  ),
  ShellDestination(
    location: '/invoices',
    labelKey: 'nav.invoices',
    icon: Icons.receipt_long_outlined,
    selectedIcon: Icons.receipt_long,
    mobile: false,
  ),
  ShellDestination(
    location: '/payments',
    labelKey: 'nav.payments',
    icon: Icons.payments_outlined,
    selectedIcon: Icons.payments,
    mobile: false,
  ),
  ShellDestination(
    location: '/billing',
    labelKey: 'nav.billing',
    icon: Icons.account_balance_wallet_outlined,
    selectedIcon: Icons.account_balance_wallet,
  ),
  ShellDestination(
    location: '/profile',
    labelKey: 'nav.profile',
    icon: Icons.person_outline,
    selectedIcon: Icons.person,
  ),
];

class ResponsiveScaffold extends StatelessWidget {
  const ResponsiveScaffold({
    super.key,
    required this.navigationShell,
    required this.i18n,
    required this.userName,
    this.unreadCount = 0,
  });

  final StatefulNavigationShell navigationShell;
  final I18nBundle i18n;
  final String userName;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= AppConstants.desktopBreakpoint;
    final destinations = isDesktop
        ? shellDestinations
              .where((item) => item.location != '/billing')
              .toList()
        : shellDestinations.where((item) => item.mobile).toList();

    final location = normalizeLocation(GoRouterState.of(context).uri.path);
    final selected = _selectedIndex(destinations, isDesktop: isDesktop);
    final sectionRoot = isShellSectionRoot(location);
    final headerDestination = _headerDestination(
      location,
      destinations[selected],
    );

    final header = AppHeader(
      title: i18n.t(headerDestination.labelKey),
      subtitle: _subtitle(headerDestination.location),
      showBack: false,
      actions: [_NotificationButton(i18n: i18n, unreadCount: unreadCount)],
    );

    final scaffold = isDesktop
        ? Scaffold(
            body: Row(
              children: [
                _SideNav(
                  i18n: i18n,
                  destinations: destinations,
                  selectedIndex: selected,
                  userName: userName,
                  onSelect: (index) => _openDestination(destinations, index),
                ),
                Expanded(
                  child: sectionRoot
                      ? Column(
                          children: [
                            SizedBox(
                              height: header.preferredSize.height,
                              width: double.infinity,
                              child: header,
                            ),
                            Expanded(child: navigationShell),
                          ],
                        )
                      : navigationShell,
                ),
              ],
            ),
          )
        : Scaffold(
            appBar: sectionRoot ? header : null,
            body: navigationShell,
            bottomNavigationBar: _BottomNavBar(
              i18n: i18n,
              destinations: destinations,
              selectedIndex: selected,
              onSelect: (index) => _openDestination(destinations, index),
            ),
          );

    return BackButtonListener(
      onBackButtonPressed: () => _handleSystemBack(context),
      child: scaffold,
    );
  }

  int _selectedIndex(
    List<ShellDestination> destinations, {
    required bool isDesktop,
  }) {
    final branch = shellDestinations[navigationShell.currentIndex];
    var selected = destinations.indexWhere(
      (item) => item.location == branch.location,
    );
    if (selected < 0 &&
        !isDesktop &&
        (branch.location == '/invoices' || branch.location == '/payments')) {
      selected = destinations.indexWhere((item) => item.location == '/billing');
    }
    if (selected < 0) return 0;
    return selected;
  }

  ShellDestination _headerDestination(
    String location,
    ShellDestination selected,
  ) {
    for (final item in shellDestinations) {
      if (item.location == location) return item;
    }
    return selected;
  }

  String? _subtitle(String location) {
    if (location == '/home' && userName.isNotEmpty) {
      return i18n.t('home.greeting', {'name': userName});
    }
    if (location == '/profile') return i18n.t('profile.headerSubtitle');
    if (location == '/shipments') return i18n.t('shipment.headerSubtitle');
    if (location == '/jobs') return i18n.t('job.headerSubtitle');
    return null;
  }

  void _openDestination(List<ShellDestination> destinations, int index) {
    final branchIndex = shellDestinations.indexWhere(
      (item) => item.location == destinations[index].location,
    );
    if (branchIndex < 0) return;
    navigationShell.goBranch(
      branchIndex,
      initialLocation: branchIndex == navigationShell.currentIndex,
    );
  }

  Future<bool> _handleSystemBack(BuildContext context) async {
    final router = GoRouter.of(context);
    if (router.canPop()) return false;
    final path = GoRouterState.of(context).uri.path;
    if (!isShellSectionRoot(path)) {
      router.go(sectionFallback(path));
      return true;
    }
    if (navigationShell.currentIndex != 0) {
      navigationShell.goBranch(0);
      return true;
    }
    return false;
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({
    required this.i18n,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelect,
  });

  final I18nBundle i18n;
  final List<ShellDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                for (var index = 0; index < destinations.length; index++)
                  Expanded(
                    child: _BottomNavItem(
                      destination: destinations[index],
                      label: destinations[index].label(i18n, compact: true),
                      selected: index == selectedIndex,
                      onTap: () => onSelect(index),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.destination,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final ShellDestination destination;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.navy : AppColors.muted;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              height: 3,
              width: selected ? 22 : 0,
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      width: 36,
                      height: 32,
                      decoration: BoxDecoration(
                        color: selected ? AppColors.mist : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: Icon(
                        selected ? destination.selectedIcon : destination.icon,
                        size: 22,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: color,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        fontSize: 11,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SideNav extends StatelessWidget {
  const _SideNav({
    required this.i18n,
    required this.destinations,
    required this.selectedIndex,
    required this.userName,
    required this.onSelect,
  });

  final I18nBundle i18n;
  final List<ShellDestination> destinations;
  final int selectedIndex;
  final String userName;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.isWide ? 276 : 260,
      color: AppColors.navyDeep,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
              child: Row(
                children: [
                  const BrandMark(size: 40, light: true),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          i18n.t('app.name'),
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          i18n.t('app.customer'),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.navyMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: destinations.length,
                itemBuilder: (context, index) {
                  final item = destinations[index];
                  final selected = index == selectedIndex;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Material(
                      color: selected
                          ? const Color(0x1AFFFFFF)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppTheme.radius),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppTheme.radius),
                        onTap: () => onSelect(index),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                selected ? item.selectedIcon : item.icon,
                                color: selected
                                    ? AppColors.amber
                                    : AppColors.navyMuted,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  i18n.t(item.labelKey),
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: AppColors.white,
                                        fontWeight: selected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                ),
                              ),
                              if (selected)
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    gradient: AppColors.accentGradient,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0x14FFFFFF),
                  borderRadius: BorderRadius.circular(AppTheme.radius),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.amberSoft,
                      child: Text(
                        userName.isEmpty
                            ? 'C'
                            : userName.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.onNeon,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.i18n, required this.unreadCount});

  final I18nBundle i18n;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: i18n.t('nav.notifications'),
      onPressed: () => context.push('/notifications'),
      icon: Badge(
        isLabelVisible: unreadCount > 0,
        label: Text('$unreadCount'),
        backgroundColor: AppColors.amber,
        child: const Icon(Icons.notifications_outlined, color: AppColors.white),
      ),
    );
  }
}
