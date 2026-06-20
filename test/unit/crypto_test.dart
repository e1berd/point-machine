import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:point_machine/core/identity.dart';
import 'package:point_machine/crypto/aead.dart';
import 'package:point_machine/crypto/folder_key.dart';
import 'package:test/test.dart';

File _identityFile() =>
    File('${Directory.systemTemp.createTempSync().path}/identity.json');

void main() {
  test('identity is stable across reloads and signs verifiably', () async {
    final file = _identityFile();
    final first = await IdentityService(file).loadOrCreate();
    final second = await IdentityService(file).loadOrCreate();
    expect(first.id, equals(second.id));

    final message = [1, 2, 3, 4];
    final signature = await first.sign(message);
    final verified = await Ed25519().verify(
      message,
      signature: Signature(signature, publicKey: first.signingPublicKey),
    );
    expect(verified, isTrue);
  });

  test('both peers derive an identical folder key', () async {
    final alice = await IdentityService(_identityFile()).loadOrCreate();
    final bob = await IdentityService(_identityFile()).loadOrCreate();
    const swarm = [7, 7, 7, 7, 7, 7, 7, 7];

    final aliceKey = await deriveFolderKey(
      agreementKeyPair: alice.agreement,
      peerPublicKey: bob.agreementPublicKey,
      swarmSecret: swarm,
    );
    final bobKey = await deriveFolderKey(
      agreementKeyPair: bob.agreement,
      peerPublicKey: alice.agreementPublicKey,
      swarmSecret: swarm,
    );
    expect(await aliceKey.extractBytes(), equals(await bobKey.extractBytes()));
  });

  test('cipher seals to ciphertext and opens back to the original', () async {
    final cipher = FolderCipher(SecretKey(List<int>.filled(32, 9)));
    final clear = List<int>.generate(2000, (i) => i % 256);

    final sealed = await cipher.seal(clear);
    expect(sealed, isNot(equals(clear)));
    expect(await cipher.open(sealed), equals(clear));
  });
}
