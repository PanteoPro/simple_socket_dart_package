import 'dart:async';

import 'package:simple_socket/simple_socket.dart';
import 'package:test/test.dart';

void main() {
  test('Server to client simple message', () async {
    final clientMessageCompleter = Completer<String>();
    final clientMessageCompleter2 = Completer<String>();
    final server = SimpleSocketServer();
    final client = SimpleSocketClient(
      onDataServer: (messages) {
        if (!clientMessageCompleter.isCompleted) {
          clientMessageCompleter.complete(messages.first);
        } else {
          clientMessageCompleter2.complete(messages.first);
        }
      },
    );

    await server.start(ip: '127.0.0.1', port: 7777);
    await client.connect(ip: '127.0.0.1', port: 7777);

    var serverMessage = 'Heelo wrold 1';
    server.sendSimpleMessages(serverMessage);

    var actual = await clientMessageCompleter.future;

    expect(actual, serverMessage);

    final serverMessage2 = 'Heelo wrold 2';
    server.sendSimpleMessage(server.socketClients.first, serverMessage2);

    final actual2 = await clientMessageCompleter2.future;

    expect(actual2, serverMessage2);

    client.close();
    server.close();
  });
}
