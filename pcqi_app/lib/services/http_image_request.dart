import 'dart:async';
import 'package:web_socket/web_socket.dart';

class HttpImageRequest {
  final urlSocket = "wss://miguel15468-pcqi-ai-api.hf.space/ws/predict";

  Future<WebSocket?> connectToSocket(String machineID) async {
    try {
      final socket = await WebSocket.connect(
        Uri.parse('$urlSocket?machine_id=$machineID'),
      );

      return socket;
    } catch (e) {
      return null;
    }
  }
}
