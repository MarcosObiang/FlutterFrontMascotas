import 'package:mascotas_citas/Modules/MessagesModule/MessagesModuleStarter.dart';
import 'package:mascotas_citas/Modules/MessagesModule/repo/messages_repository.dart';
import 'package:mascotas_citas/Modules/MessagesModule/state/MessagesState.dart';
import 'package:mascotas_citas/Modules/MessagesModule/usecases/GetMessagesUseCase.dart';
import 'package:mascotas_citas/dependencies/injector.dart';

class MessagesModuleInjector {
  static  void init()  {
    // Register your dependencies here
    // Example:
    // GetIt.I.registerLazySingleton<YourService>(() => YourServiceImpl());


  getIt.registerSingleton<MessagesState>(MessagesState());
    getIt.registerSingleton<MessagesRepository>(MessagesRepositoryImpl(
      webSocketService: getIt(),
      dioApiService: getIt(),
    ));

    getIt.registerSingleton<GetMessagesUseCase>(GetMessagesUseCase(
          messagesRepository: getIt<MessagesRepository>(),
          messagesState: getIt<MessagesState>(),
        ));

    getIt.registerSingleton<MessagesModuleStarter>(
      MessagesModuleStarter(
        selfStartedUseCases: [
          getIt<GetMessagesUseCase>(),

        ],
        messagesState: getIt<MessagesState>(),
      ),
    );
  }
}
