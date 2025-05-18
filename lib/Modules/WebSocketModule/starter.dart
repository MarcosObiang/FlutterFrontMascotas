


import 'package:mascotas_citas/Modules/WebSocketModule/WebSocketInitUseCase.dart';
import 'package:mascotas_citas/interfaces/starter_interface.dart';

class WebSocketStarter implements IStarterInterface {
  final WebSocketInitUseCase webSocketInitUseCase;
  WebSocketStarter({required this.webSocketInitUseCase});
  @override
  Future<void> init() async {
    await webSocketInitUseCase.execute();
  }
  
  @override
  Future<void> dispose() {
    // TODO: implement dispose
    throw UnimplementedError();
  }
}