import 'dart:async';
import 'package:web_socket/web_socket.dart';

class HttpImageRequest {
  final urlSocket = "wss://miguel15468-pcqi-ai-api.hf.space/ws/predict";

  Future<WebSocket> connectToSocket() async {
    final socket = await WebSocket.connect(Uri.parse(urlSocket));

    return socket;
  }
}
