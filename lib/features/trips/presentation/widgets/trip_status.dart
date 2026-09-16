import 'package:flutter/material.dart';

import '../../../../core/i18n/i18n_controller.dart';
import '../../../../shared/widgets/app_glyph.dart';
import '../../data/customer_trip_progress.dart';

IconData tripStatusIcon(String? status) {
  return switch (CustomerTripProgress.stageOf(status)) {
    CustomerTripProgress.loaded => Icons.inventory_2_rounded,
    CustomerTripProgress.inTransit => Icons.local_shipping_rounded,
    CustomerTripProgress.delivered => Icons.flag_rounded,
    CustomerTripProgress.cancelled => Icons.cancel_outlined,
    _ => Icons.person_pin_circle_rounded,
  };
}

AppGlyphTone tripStatusTone(String? status) {
  return switch (CustomerTripProgress.stageOf(status)) {
    CustomerTripProgress.assigned => AppGlyphTone.muted,
    CustomerTripProgress.loaded ||
    CustomerTripProgress.inTransit => AppGlyphTone.navy,
    CustomerTripProgress.delivered => AppGlyphTone.success,
    CustomerTripProgress.cancelled => AppGlyphTone.danger,
    _ => AppGlyphTone.navy,
  };
}

String customerTripStageLabel(I18nBundle i18n, String? status) {
  final stage = CustomerTripProgress.stageOf(status);
  if (stage == CustomerTripProgress.cancelled) {
    return i18n.status('cancelled');
  }
  return i18n.t('trip.stage.$stage');
}

String customerTripStageHint(I18nBundle i18n, String? status) {
  final stage = CustomerTripProgress.stageOf(status);
  return i18n.t('trip.stageHint.$stage');
}
