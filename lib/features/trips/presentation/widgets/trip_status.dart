import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_glyph.dart';

IconData tripStatusIcon(String? status) {
  return switch (status) {
    'assigned' => Icons.person_pin_circle_rounded,
    'arrived_at_pickup' => Icons.trip_origin_rounded,
    'loaded' => Icons.inventory_2_rounded,
    'in_transit' => Icons.local_shipping_rounded,
    'arrived' => Icons.place_rounded,
    'delivered' => Icons.flag_rounded,
    'completed' => Icons.verified_rounded,
    'cancelled' => Icons.cancel_outlined,
    _ => Icons.alt_route_rounded,
  };
}

AppGlyphTone tripStatusTone(String? status) {
  return switch (status) {
    'assigned' || 'arrived_at_pickup' => AppGlyphTone.muted,
    'loaded' || 'in_transit' || 'arrived' => AppGlyphTone.navy,
    'delivered' || 'completed' => AppGlyphTone.success,
    'cancelled' => AppGlyphTone.danger,
    _ => AppGlyphTone.navy,
  };
}
