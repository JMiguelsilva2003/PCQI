import 'dart:async';

import 'package:web_socket/web_socket.dart';

class HttpImageRequest {
  final urlSocket = "wss://miguel15468-pcqi-ai-api.hf.space/ws/predict";

  Future<WebSocket> connectToSocket() async {
    final socket = await WebSocket.connect(Uri.parse(urlSocket));

    socket.events.listen((e) async {
      switch (e) {
        case TextDataReceived(text: final text):
          print('Received Text: $text');
        case BinaryDataReceived(data: final data):
          print('Received Binary: $data');
        case CloseReceived(code: final code, reason: final reason):
          print('Connection to server closed: $code [$reason]');
      }
    });

    return socket;
  }
}
