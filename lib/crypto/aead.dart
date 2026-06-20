import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

class FolderCipher {
  FolderCipher(this.key);

  final SecretKey key;

  static final _algorithm = Xchacha20.poly1305Aead();
  static const _nonceLength = 24;
  static const _macLength = 16;

  Future<Uint8List> seal(List<int> clear) async {
    final box = await _algorithm.encrypt(clear, secretKey: key);
    return box.concatenation();
  }

  Future<List<int>> open(Uint8List sealed) {
    final box = SecretBox.fromConcatenation(
      sealed,
      nonceLength: _nonceLength,
      macLength: _macLength,
    );
    return _algorithm.decrypt(box, secretKey: key);
  }
}
