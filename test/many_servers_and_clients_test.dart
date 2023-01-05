import 'dart:async';

import 'package:simple_socket/simple_socket.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  test('Many servers and clients', () async {
    final countServers = 500;
    final countClientsOnServer = 3;
    final countMessagesOnClient = 100;
    final ports = List.generate(countServers, (index) => 9352 + index);
    final servers = <SimpleSocketServer>[];
    final clients = <SimpleSocketClient>[];
    final allMessages = <String>[];

    final completer = Completer<bool>();

    for (final index in List.generate(countServers, (index) => index)) {
      servers.add(
        SimpleSocketServer(
          onServerStarted: () {
            print('SERVER #$index started');
          },
          onDataClient: (client, messages) {
            print('SERVER #$index recieve message - ${messages.length}');
            for (final message in messages) {
              allMessages.add(message);
            }
            if (allMessages.length ==
                countServers * countClientsOnServer * countMessagesOnClient) {
              completer.complete(true);
            }
          },
        ),
      );
      await servers[index].start(ip: '127.0.0.1', port: ports[index]);
    }

    for (final index in List.generate(countServers, (index) => index)) {
      for (final j in List.generate(countClientsOnServer, (index) => index)) {
        final newClient = SimpleSocketClient();
        clients.add(newClient);
        await newClient.connect(ip: '127.0.0.1', port: ports[index]);
      }
    }

    for (final client in clients) {
      for (final indexMessage
          in List.generate(countMessagesOnClient, (index) => index)) {
        client.sendSimpleMessage('1');
        print('send message');
      }
    }

    await completer.future;

    expect(allMessages.length,
        countServers * countClientsOnServer * countMessagesOnClient);

    for (final client in clients) {
      client.close();
    }
    for (final server in servers) {
      server.close();
    }
  });
}
