import 'package:mascotas_citas/Modules/ProfileModule/state/settingsState.dart';
import 'package:mascotas_citas/interfaces/self_started_use_case_interface.dart';
import 'package:mascotas_citas/interfaces/starter_interface.dart';

class Profilemodulestarter implements IStarterInterface {
  List<ISelfStartedUseCaseInterface> useCases = [];
  SettingsState settingsState;


  Profilemodulestarter({required this.useCases, required this.settingsState});

  @override
  Future<void> dispose() {
    // TODO: implement dispose
    throw UnimplementedError();
  }

  @override
  Future<void> init() {
    try {
      settingsState.initialize();
      for (var useCase in useCases) {
        useCase.init();
      }
    } catch (e) {
      print("Error initializing use cases: $e");
      // Handle the error as needed
      // For example, you might want to log it or show a message to the user
      // throw e; // Rethrow the error if you want to propagate it
    }
    return Future.value();
  }
}
