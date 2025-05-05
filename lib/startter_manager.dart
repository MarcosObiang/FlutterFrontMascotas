import 'package:mascotas_citas/Modules/AuthenticationModule/usecases/SelfLogInWithLoginUseCase.dart';
import 'package:mascotas_citas/interfaces/starter_interface.dart';

typedef isUserAbleToLogInAutomaticallyCallback = void Function(
    {required bool value});

class StarterManager {
  CheckIfUsserCanLogInUseCase selfLoginWithGoogleUseCase;
  isUserAbleToLogInAutomaticallyCallback? canUserLogIn;
  List<IStarterInterface> starters;
  StarterManager(
      {required this.selfLoginWithGoogleUseCase, required this.starters});

  Future<void> startAuth() async {
    try {
      bool isUserAlreadyRegistered = await selfLoginWithGoogleUseCase.execute();
      if (isUserAlreadyRegistered) {
        canUserLogIn!.call(value: true);

      } else {
        canUserLogIn!.call(value: false);
      }
    } catch (e) {}
  }

  Future<void> start() async {
    for (var starter in starters) {
      await starter.init();
    }
     await  startAuth();
     Future.value(null);
  
  }
}
