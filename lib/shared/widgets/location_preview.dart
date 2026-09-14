import 'package:flutter/material.dart';

import '../../core/i18n/i18n_controller.dart';
import '../../core/maps/google_maps_links.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import 'app_glyph.dart';

class LocationPreview extends StatelessWidget {
  const LocationPreview({
    super.key,
    required this.i18n,
    required this.title,
    this.address,
    this.city,
    this.lat,
    this.lng,
    this.navigate = false,
  });

  final I18nBundle i18n;
  final String title;
  final String? address;
  final String? city;
  final double? lat;
  final double? lng;
  final bool navigate;

  bool get _hasCoords => lat != null && lng != null;

  @override
  Widget build(BuildContext context) {
    final line = [
      if ((address ?? '').trim().isNotEmpty) address!.trim(),
      if ((city ?? '').trim().isNotEmpty) city!.trim(),
    ].join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AppGlyph(
              icon: navigate ? Icons.near_me_rounded : Icons.place_rounded,
              size: 32,
              iconSize: 16,
              tone: navigate ? AppGlyphTone.neon : AppGlyphTone.navy,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          line.isEmpty ? i18n.t('common.notAvailable') : line,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        if (_hasCoords) ...[
          const SizedBox(height: 4),
          Text(
            formatCoordinates(lat, lng),
            style: const TextStyle(color: AppColors.muted),
          ),
          TextButton.icon(
            onPressed: () => GoogleMapsLinks.open(lat: lat!, lng: lng!, navigate: navigate),
            icon: Icon(navigate ? Icons.near_me_rounded : Icons.map_rounded, size: 18),
            label: Text(
              navigate ? i18n.t('location.navigate') : i18n.t('location.openInGoogleMaps'),
            ),
          ),
        ],
      ],
    );
  }
}
