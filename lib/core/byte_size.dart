String formatBytes(int bytes, List<String> units) {
  if (bytes <= 0) return '0 ${units.first}';
  var size = bytes.toDouble();
  var unit = 0;
  while (size >= 1024 && unit < units.length - 1) {
    size /= 1024;
    unit++;
  }
  final value = size == size.roundToDouble() || size >= 100
      ? size.round().toString()
      : size.toStringAsFixed(1);
  return '$value ${units[unit]}';
}
