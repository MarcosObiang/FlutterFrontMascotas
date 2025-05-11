import 'dart:async';
import 'dart:convert';
import 'package:mascotas_citas/const_values/const_values.dart';
import 'package:mascotas_citas/services/auth/AuthSesionDataService.dart';
import 'dart:io';

class WebSocketService {
  final AuthDataService authDataService;
  late StreamController<Map<String, dynamic>> onMessageReceived;
  WebSocket? _webSocket;
  Timer? _reconnectTimer;
  String? token;
  String? userUID;
  final Uri wsUri =
      Uri.parse("wss://${ConstValues.hostName}/realtime-service/ws/updates");

  WebSocketService({required this.authDataService}) {
    _init();
  }

  void _init() {
    authDataService.onAuthDataChanged.stream.listen((event) {
      String? token = event["token"];
      String? userUID = event["userUID"];

      this.token = token;
      this.userUID = userUID;

      if (this.token != null) {
        _connectWebSocket();
      } else {
        _webSocket?.close();
        _reconnectTimer?.cancel();
      }
    });

    onMessageReceived = StreamController.broadcast();
  }

  void dispose() {
    onMessageReceived.close();
  }

  Future<void> _connectWebSocket() async {
    try {
      print("Conectando a WebSocket...");
      _webSocket = await WebSocket.connect(
        wsUri.toString(),
        headers: {"Authorization": "Bearer ${this.token}"},
      );
      Timer.periodic(Duration(seconds: 10), (_) {
        if (_webSocket?.readyState == WebSocket.open) {
          _webSocket?.add('ping');
        }
      });

      _webSocket!.listen(
        (message) => _handleMessage(message),
        onError: (error) => _handleError(error),
        onDone: () => _handleDisconnect(),
      );

      print("✅ Conectado correctamente!");
    } catch (e) {
      print("⚠️ Error al conectar: $e");
      _scheduleReconnect();
    }
  }

  void _handleMessage(String message) {
    print("📩 Mensaje recibido: $message");
    onMessageReceived.add(jsonDecode(message));
  }

  void _handleError(error) {
    print("❌ Error en WebSocket: $error");
    _scheduleReconnect();
  }

  void _handleDisconnect() {
    print("🔴 WebSocket desconectado. Intentando reconectar...");
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: 5), _connectWebSocket);
  }

  void sendMessage(String message) {
    _webSocket?.add(message);
  }

  void close() {
    _webSocket?.close();
    _reconnectTimer?.cancel();
  }
}
