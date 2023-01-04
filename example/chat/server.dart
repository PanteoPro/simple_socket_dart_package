import 'package:simple_socket/src/server.dart';

Future<void> main() async {
  late final SimpleSocketServer server;
  server = SimpleSocketServer(
    onServerStarted: () {
      print(
          'SERVER: Server started at ${server.ipServer}:${server.portServer}');
    },
    onConnectedClient: (client) {
      print(
          'SERVER: Client ${client.remoteAddress.address}:${client.remotePort} connected');
      server.sendMessage(client, {'data': 'Welcome to server Client'});
      server.sendMessages({
        'data':
            'SERVER: Client ${client.remoteAddress.address}:${client.remotePort} connected'
      });
    },
    onDataClient: (client, messages) {
      for (final message in messages) {
        print(
            'SERVER (Recieve the message) from Client ${client.remoteAddress.address}:${client.remotePort}: $message');
        server.sendMessages(
          {
            'data':
                'Client ${client.remoteAddress.address}:${client.remotePort}: $message'
          },
          excludeClients: [client],
        );
      }
    },
    onDoneClient: (client) {
      print(
          'SERVER: Client ${client.remoteAddress.address}:${client.remotePort} was left');
      server.sendMessages({
        'data':
            'SERVER: Client ${client.remoteAddress.address}:${client.remotePort} was left'
      });
    },
  );
  await server.start(ip: '127.0.0.1', port: 7777);
}
