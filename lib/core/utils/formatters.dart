import 'package:intl/intl.dart';

String formatAmount(num? value, {String currency = 'OMR'}) {
  if (value == null) return '—';
  final formatted = NumberFormat('#,##0.000', 'en').format(value);
  return '$formatted $currency';
}

String formatNumber(num? value, {int decimals = 2}) {
  if (value == null) return '—';
  return NumberFormat('#,##0.${'0' * decimals}', 'en').format(value);
}

String formatPercent(num? value) {
  if (value == null) return '—';
  return '${value.toStringAsFixed(0)}%';
}

String formatDate(DateTime? value, {String locale = 'en'}) {
  if (value == null) return '—';
  return latinDigits(DateFormat.yMMMd(locale).format(value.toLocal()));
}

String formatDateTime(DateTime? value, {String locale = 'en'}) {
  if (value == null) return '—';
  return latinDigits(DateFormat.yMMMd(locale).add_jm().format(value.toLocal()));
}

String latinDigits(String value) {
  const easternArabic = '٠١٢٣٤٥٦٧٨٩';
  const persian = '۰۱۲۳۴۵۶۷۸۹';
  final buffer = StringBuffer();
  for (final rune in value.runes) {
    final char = String.fromCharCode(rune);
    final easternIndex = easternArabic.indexOf(char);
    if (easternIndex >= 0) {
      buffer.write(easternIndex);
      continue;
    }
    final persianIndex = persian.indexOf(char);
    if (persianIndex >= 0) {
      buffer.write(persianIndex);
      continue;
    }
    buffer.write(char);
  }
  return buffer.toString();
}

String formatCoordinate(num? value) {
  if (value == null) return '—';
  return value.toStringAsFixed(5);
}

String formatCoordinates(num? lat, num? lng) {
  if (lat == null || lng == null) return '—';
  return '${formatCoordinate(lat)}, ${formatCoordinate(lng)}';
}

String mediaUrl(String? path, String storageBase) {
  if (path == null || path.isEmpty) return '';
  if (path.startsWith('http://') || path.startsWith('https://')) return path;
  final cleaned = path.startsWith('/') ? path.substring(1) : path;
  return '$storageBase/$cleaned';
}
