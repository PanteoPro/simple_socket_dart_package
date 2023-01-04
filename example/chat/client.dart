import 'dart:async';

import 'package:simple_socket/src/client.dart';

Future<void> main() async {
  late final SimpleSocketClient client;
  client = SimpleSocketClient(
    onConnectedServer: () {
      print('Client connected to ${client.ipServer}:${client.portServer}');
    },
    onDataServer: (messages) {
      for (final message in messages) {
        print(message);
      }
    },
  );
  await client.connect(ip: '127.0.0.1', port: 7777);
  Timer.periodic(Duration(seconds: 1), (timer) {
    client.sendMessage({"data": "Hello Server"});
  });
}
