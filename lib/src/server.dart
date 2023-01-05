import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import './app_const.dart';
import './exceptions/exception_already_server_started.dart';

class SimpleSocketServer {
  SimpleSocketServer({
    this.onServerStarted,
    this.onConnectedClient,
    this.onDataClient,
    this.onErrorClient,
    this.onDoneClient,
  });

  final void Function()? onServerStarted;
  final void Function(Socket client)? onConnectedClient;
  final void Function(Socket client, List<String> messages)? onDataClient;
  final void Function(Socket client, dynamic error)? onErrorClient;
  final void Function(Socket client)? onDoneClient;

  ServerSocket? _server;
  ServerSocket? get serverSocket => _server;

  final List<Socket> _clients = [];

  List<Socket> get socketClients => [..._clients];

  String? _ip;
  int? _port;

  String? get ipServer => _ip;
  int? get portServer => _port;

  void close() {
    _server?.close();
  }

  Future<void> start({
    required String ip,
    required int port,
  }) async {
    if (_server != null) throw ExceptionAlreadyServerStarted();
    _server = await ServerSocket.bind(ip, port);
    _ip = ip;
    _port = port;
    onServerStarted?.call();
    _server!.listen(_onClientConnected);
  }

  void _onClientConnected(Socket client) {
    onConnectedClient?.call(client);
    _clients.add(client);
    client.listen(
      (data) => _onDataRecieve(client, data),
      onError: (error) => _onErrorRecieve(client, error),
      onDone: () => _onDoneRecieve(client),
    );
  }

  void _onDataRecieve(Socket client, Uint8List data) {
    final dataString = const Utf8Decoder().convert(data);
    final cuttedDataString = dataString.substring(0, dataString.length - 1);
    final splittedDataString =
        cuttedDataString.split(SimpleSocketConst.messageSeparator);
    onDataClient?.call(client, splittedDataString);
  }

  void _onErrorRecieve(Socket client, dynamic error) {
    _clients.remove(client);
    onErrorClient?.call(client, error);
  }

  void _onDoneRecieve(Socket client) {
    _clients.remove(client);
    onDoneClient?.call(client);
  }

  void sendSimpleMessage(Socket client, String message) {
    _sendMessageWrapper(client, message);
  }

  void sendSimpleMessages(String message, {List<Socket>? excludeClients}) {
    for (final client in _clients) {
      if (!(excludeClients?.contains(client) ?? false)) {
        _sendMessageWrapper(client, message);
      }
    }
  }

  void sendMessage(Socket client, Map<String, dynamic> message) {
    _sendMessageWrapper(client, jsonEncode(message));
  }

  void sendMessages(Map<String, dynamic> message,
      {List<Socket>? excludeClients}) {
    for (final client in _clients) {
      if (!(excludeClients?.contains(client) ?? false)) {
        _sendMessageWrapper(client, jsonEncode(message));
      }
    }
  }

  void _sendMessageWrapper(Socket client, String message) {
    client.write('$message${SimpleSocketConst.messageSeparator}');
  }
}
