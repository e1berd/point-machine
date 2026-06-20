const _alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';

String base32Encode(List<int> bytes) {
  final output = StringBuffer();
  var buffer = 0;
  var bits = 0;
  for (final byte in bytes) {
    buffer = (buffer << 8) | byte;
    bits += 8;
    while (bits >= 5) {
      bits -= 5;
      output.write(_alphabet[(buffer >> bits) & 0x1f]);
    }
  }
  if (bits > 0) {
    output.write(_alphabet[(buffer << (5 - bits)) & 0x1f]);
  }
  return output.toString();
}

String hexEncode(List<int> bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
