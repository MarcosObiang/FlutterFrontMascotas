import 'package:mascotas_citas/interfaces/self_started_use_case_interface.dart';
import 'package:mascotas_citas/services/WebSocketService.dart';

class WebSocketInitUseCase implements ISelfStartedUseCaseInterface {
  final WebSocketService webSocketService;
  WebSocketInitUseCase({required this.webSocketService});
  @override
  Future<void> execute() {
    webSocketService.init();
    return Future.value(null);
  }

  @override
  Future<void> init() {
    this.execute();
    return Future.value(null);
  }
}
