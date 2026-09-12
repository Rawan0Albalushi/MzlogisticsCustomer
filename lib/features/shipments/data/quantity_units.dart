import '../../../core/i18n/i18n_controller.dart';
import '../../../core/utils/formatters.dart';

class QuantityUnits {
  static const tons = 'tons';
  static const pallets = 'pallets';
  static const units = 'units';

  static const values = [tons, pallets, units];

  static String normalize(String? raw) {
    switch ((raw ?? '').toLowerCase().trim()) {
      case 'pallet':
      case 'pallets':
        return pallets;
      case 'unit':
      case 'units':
        return units;
      default:
        return tons;
    }
  }

  static bool isTons(String? raw) {
    final key = (raw ?? '').toLowerCase().trim();
    return key.isEmpty || key == 'ton' || key == 'tons';
  }

  static String label(I18nBundle i18n, String? raw) {
    switch ((raw ?? '').toLowerCase().trim()) {
      case 'pallet':
      case 'pallets':
        return i18n.t('shipment.unitPallets');
      case 'unit':
      case 'units':
        return i18n.t('shipment.unitUnits');
      case 'load':
      case 'loads':
        return i18n.t('shipment.unitLoads');
      default:
        return i18n.t('shipment.unitTons');
    }
  }

  static String countFieldLabel(I18nBundle i18n, String unit) {
    return switch (normalize(unit)) {
      pallets => i18n.t('shipment.palletCount'),
      units => i18n.t('shipment.unitCount'),
      _ => i18n.t('shipment.quantity'),
    };
  }

  static String measureHint(I18nBundle i18n, String unit) {
    return switch (normalize(unit)) {
      pallets => i18n.t('shipment.measurePalletsHint'),
      units => i18n.t('shipment.measureUnitsHint'),
      _ => i18n.t('shipment.measureTonsHint'),
    };
  }

  static String formatQuantity(I18nBundle i18n, num? quantity, String? unit) {
    return '${formatNumber(quantity)} ${label(i18n, unit)}';
  }

  static String cargoSummary(I18nBundle i18n, {num? weightTons, num? quantity, String? unit}) {
    final weight = '${formatNumber(weightTons)} ${i18n.t('common.tons')}';
    if (isTons(unit)) {
      return weight;
    }
    return '${formatQuantity(i18n, quantity, unit)} · $weight';
  }
}
