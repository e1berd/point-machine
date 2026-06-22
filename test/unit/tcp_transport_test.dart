import 'dart:io';

import 'package:mesh_market/transport/messages.dart';
import 'package:mesh_market/transport/tcp_transport.dart';
import 'package:test/test.dart';

void main() {
  test('buffers sync messages that arrive immediately after open', () async {
    final server = DirectTcpTransport(deviceId: 'B');
    final clientTransport = DirectTcpTransport(deviceId: 'A');
    await server.start();
    addTearDown(server.stop);
    addTearDown(clientTransport.stop);
    final incomingFuture = server.incoming.first.timeout(
      const Duration(seconds: 2),
    );

    final client = await clientTransport.open(
      address: InternetAddress.loopbackIPv4,
      port: server.boundPort,
      peerId: 'B',
      folderId: 'folder',
    );

    await client.send(WantBlock('file.txt', 3));

    final incoming = await incomingFuture;
    final message = await incoming.link.incoming.first.timeout(
      const Duration(seconds: 2),
    );

    expect(incoming.peerId, 'A');
    expect(incoming.folderId, 'folder');
    expect(message, isA<WantBlock>());
    expect((message as WantBlock).path, 'file.txt');
    expect(message.index, 3);

    await incoming.link.close();
    await client.close();
  });
}
