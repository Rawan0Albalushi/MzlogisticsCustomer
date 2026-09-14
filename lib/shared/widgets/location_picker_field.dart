import 'package:flutter/material.dart';

import '../../core/i18n/i18n_controller.dart';
import '../../core/maps/google_maps_links.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../features/places/presentation/location_picker_screen.dart';
import '../models/geo_location.dart';

class LocationPickerField extends StatelessWidget {
  const LocationPickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.i18n,
  });

  final String label;
  final GeoLocation? value;
  final ValueChanged<GeoLocation> onChanged;
  final I18nBundle i18n;

  Future<void> _open(BuildContext context) async {
    final selected = await LocationPickerScreen.open(
      context,
      title: label,
      initial: value,
    );
    if (selected != null) {
      onChanged(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = value;
    return Material(
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _open(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.map_outlined, color: AppColors.amber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  Text(
                    selected == null ? i18n.t('location.pickOnMap') : i18n.t('location.change'),
                    style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (selected == null)
                Text(
                  i18n.t('location.searchGoogleMaps'),
                  style: const TextStyle(color: AppColors.muted),
                )
              else ...[
                Text(selected.address, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  selected.areaLabel.isNotEmpty ? selected.areaLabel : selected.city,
                  style: const TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 6),
                Text(
                  formatCoordinates(selected.lat, selected.lng),
                  style: const TextStyle(color: AppColors.muted),
                ),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    onPressed: () => GoogleMapsLinks.open(lat: selected.lat, lng: selected.lng),
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: Text(i18n.t('location.openInGoogleMaps')),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
