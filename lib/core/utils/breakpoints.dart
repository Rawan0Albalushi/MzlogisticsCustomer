import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

extension Breakpoints on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;

  bool get isDesktop => screenWidth >= AppConstants.desktopBreakpoint;

  bool get isWide => screenWidth >= AppConstants.wideBreakpoint;

  bool get isTablet =>
      screenWidth >= AppConstants.tabletBreakpoint &&
      screenWidth < AppConstants.desktopBreakpoint;

  bool get isMobile => screenWidth < AppConstants.tabletBreakpoint;

  double get contentMaxWidth {
    if (screenWidth >= 1920) return 1760;
    if (screenWidth >= 1600) return 1520;
    if (screenWidth >= 1280) return 1280;
    return 1100;
  }

  EdgeInsets get contentPadding {
    if (isWide) return const EdgeInsets.fromLTRB(28, 24, 28, 36);
    if (isDesktop) return const EdgeInsets.fromLTRB(24, 20, 24, 32);
    return const EdgeInsets.fromLTRB(20, 20, 20, 28);
  }
}
