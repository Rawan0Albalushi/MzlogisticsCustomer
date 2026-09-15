import 'package:flutter/material.dart';

import '../../core/i18n/i18n_controller.dart';
import '../../core/theme/app_colors.dart';
import 'app_button.dart';
import 'empty_state.dart';

class AppFilterOption<T> {
  const AppFilterOption({
    required this.value,
    required this.label,
    required this.icon,
    required this.count,
  });

  final T value;
  final String label;
  final IconData icon;
  final int count;
}

class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.controller,
    required this.i18n,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final I18nBundle i18n;
  final String hint;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onChanged: (_) => onChanged(),
      decoration: InputDecoration(
        labelText: i18n.t('common.search'),
        hintText: hint,
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.navy),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: i18n.t('common.clearFilters'),
                onPressed: () {
                  controller.clear();
                  onChanged();
                },
                icon: const Icon(Icons.close_rounded, size: 18),
              ),
        filled: true,
        fillColor: AppColors.white,
      ),
    );
  }
}

class AppFilterBar<T> extends StatelessWidget {
  const AppFilterBar({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<AppFilterOption<T>> options;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var index = 0; index < options.length; index++) ...[
            if (index > 0) const SizedBox(width: 8),
            _Chip(
              option: options[index],
              selected: selected == options[index].value,
              onTap: () => onSelected(options[index].value),
            ),
          ],
        ],
      ),
    );
  }
}

class AppListToolbar<T> extends StatelessWidget {
  const AppListToolbar({
    super.key,
    required this.i18n,
    required this.search,
    required this.searchHint,
    required this.onSearchChanged,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final I18nBundle i18n;
  final TextEditingController search;
  final String searchHint;
  final VoidCallback onSearchChanged;
  final List<AppFilterOption<T>> options;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSearchField(
          controller: search,
          i18n: i18n,
          hint: searchHint,
          onChanged: onSearchChanged,
        ),
        const SizedBox(height: 12),
        AppFilterBar(
          options: options,
          selected: selected,
          onSelected: onSelected,
        ),
      ],
    );
  }
}

class AppFilterEmpty extends StatelessWidget {
  const AppFilterEmpty({
    super.key,
    required this.i18n,
    required this.onClear,
  });

  final I18nBundle i18n;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      title: i18n.t('common.noMatch'),
      message: i18n.t('common.noMatchHint'),
      icon: Icons.filter_alt_off_outlined,
      action: AppButton(
        label: i18n.t('common.clearFilters'),
        variant: AppButtonVariant.secondary,
        icon: Icons.refresh_rounded,
        onPressed: onClear,
      ),
    );
  }
}

bool matchesSearch(String query, Iterable<String?> fields) {
  if (query.isEmpty) return true;
  final haystack = fields.whereType<String>().join(' ').toLowerCase();
  return haystack.contains(query);
}

class _Chip<T> extends StatelessWidget {
  const _Chip({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final AppFilterOption<T> option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.navy : AppColors.muted;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsetsDirectional.fromSTEB(10, 7, 8, 7),
          decoration: BoxDecoration(
            color: selected ? AppColors.navySoft : AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.navy.withValues(alpha: 0.35) : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(option.icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                option.label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: selected ? AppColors.navy : AppColors.ink,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    ),
              ),
              const SizedBox(width: 6),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: selected ? AppColors.navy : AppColors.mist,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${option.count}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: selected ? AppColors.white : AppColors.muted,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
