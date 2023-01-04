import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import './app_const.dart';
import './exceptions/exception_already_client_conected.dart';

class SimpleSocketClient {
  SimpleSocketClient({
    this.onConnectedServer,
    this.onDataServer,
    this.onErrorServer,
    this.onDoneServer,
  });

  final void Function()? onConnectedServer;
  final void Function(List<String> messages)? onDataServer;
  final void Function(dynamic error)? onErrorServer;
  final void Function()? onDoneServer;

  Socket? _socket;
  Socket? get socket => _socket;

  String? _ip;
  int? _port;

  String? get ipServer => _ip;
  int? get portServer => _port;

  Future<void> connect({required String ip, required int port}) async {
    if (_socket != null) throw ExceptionAlreadyClientConnected();
    _socket = await Socket.connect(ip, port);
    _ip = ip;
    _port = port;
    onConnectedServer?.call();
    _socket?.listen(
      _onDataRecieve,
      onError: _onErrorRecieve,
      onDone: _onDoneRecieve,
    );
  }

  void close() {
    _socket?.close();
  }

  void _onDataRecieve(Uint8List data) {
    final dataString = const Utf8Decoder().convert(data);
    final cuttedDataString = dataString.substring(0, dataString.length - 1);
    final splittedDataString =
        cuttedDataString.split(SimpleSocketConst.messageSeparator);
    onDataServer?.call(splittedDataString);
  }

  void _onErrorRecieve(dynamic error) {
    onErrorServer?.call(error);
    close();
  }

  void _onDoneRecieve() {
    onDoneServer?.call();
    close();
  }

  void sendMessage(Map<String, dynamic> message) {
    _socket
        ?.write('${jsonEncode(message)}${SimpleSocketConst.messageSeparator}');
  }
}
