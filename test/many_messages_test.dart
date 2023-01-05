import 'dart:async';

import 'package:simple_socket/simple_socket.dart';
import 'package:test/test.dart';

import 'package:collection/collection.dart';

void main() {
  test('Many messages client to server', () async {
    final countMessages = 10000;
    final resultMessages = <int>[];
    final isEndCompeleter = Completer<bool>();
    final server = SimpleSocketServer(
      onDataClient: (client, messages) {
        for (final message in messages) {
          resultMessages.add(int.parse(message));
        }
        if (resultMessages.length == countMessages) {
          isEndCompeleter.complete(true);
        }
      },
    );
    final client = SimpleSocketClient();

    await server.start(ip: '127.0.0.1', port: 7777);
    await client.connect(ip: '127.0.0.1', port: 7777);

    for (final i in List.generate(countMessages, (index) => index)) {
      client.sendSimpleMessage(i.toString());
    }
    await isEndCompeleter.future;

    expect(
        resultMessages.reduce((value, element) => value + element),
        List.generate(countMessages, (index) => index)
            .reduce((value, element) => value + element));
  });
}
