import 'dart:convert';

import 'package:cryptography/cryptography.dart';

const _info = 'mesh-market/folder-key/v1';

Future<SecretKey> deriveFolderKey({
  required SimpleKeyPair agreementKeyPair,
  required SimplePublicKey peerPublicKey,
  required List<int> swarmSecret,
}) async {
  final shared = await X25519().sharedSecretKey(
    keyPair: agreementKeyPair,
    remotePublicKey: peerPublicKey,
  );
  return Hkdf(hmac: Hmac.sha256(), outputLength: 32).deriveKey(
    secretKey: shared,
    nonce: swarmSecret,
    info: utf8.encode(_info),
  );
}
