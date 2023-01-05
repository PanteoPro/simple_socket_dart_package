import 'dart:async';

import 'package:simple_socket/simple_socket.dart';
import 'package:test/test.dart';

void main() {
  test('Client to server simple message', () async {
    final serverMessageCompleter = Completer<String>();
    final server = SimpleSocketServer(
      onDataClient: (client, messages) {
        serverMessageCompleter.complete(messages.first);
      },
    );
    final client = SimpleSocketClient();

    await server.start(ip: '127.0.0.1', port: 7777);
    await client.connect(ip: '127.0.0.1', port: 7777);

    final clientMessage = 'Heelo wrold';
    client.sendSimpleMessage(clientMessage);

    final actual = await serverMessageCompleter.future;

    expect(actual, clientMessage);
  });
}
