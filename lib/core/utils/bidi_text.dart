/// Isolates a name so Arabic/Latin text keeps its own direction
/// inside both RTL and LTR layouts.
String bidiIsolate(String value) {
  const fsi = '\u2068';
  const pdi = '\u2069';
  if (value.isEmpty) return value;
  if (value.startsWith(fsi) && value.endsWith(pdi)) return value;
  return '$fsi$value$pdi';
}
