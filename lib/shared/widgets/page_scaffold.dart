import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/breakpoints.dart';
import 'app_header.dart';

class PageScaffold extends StatelessWidget {
  const PageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.actions,
    this.floatingActionButton,
    this.showBack,
    this.onBack,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool? showBack;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppHeader(
        title: title,
        subtitle: subtitle,
        actions: actions,
        showBack: showBack,
        onBack: onBack,
      ),
      floatingActionButton: floatingActionButton,
      body: body,
    );
  }
}

class ContentWidth extends StatelessWidget {
  const ContentWidth({
    super.key,
    required this.child,
    this.padding,
    this.maxWidth,
  });

  final Widget child;
  final EdgeInsets? padding;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final cap = maxWidth ?? context.contentMaxWidth;
    final insets = padding ?? context.contentPadding;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth < cap ? constraints.maxWidth : cap;
        final bounded = constraints.maxHeight.isFinite;
        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: width,
            height: bounded ? constraints.maxHeight : null,
            child: Padding(padding: insets, child: child),
          ),
        );
      },
    );
  }
}
