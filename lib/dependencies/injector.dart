import 'package:get_it/get_it.dart';
import 'package:mascotas_citas/Modules/AuthenticationModule/repo/AuthenticationRepo.dart';
import 'package:mascotas_citas/Modules/AuthenticationModule/usecases/LogInWithGoogleUseCase.dart';
import 'package:mascotas_citas/Modules/AuthenticationModule/usecases/SelfLogInWithLoginUseCase.dart';
import 'package:mascotas_citas/Modules/ChatModule/chat_starter.dart';
import 'package:mascotas_citas/Modules/ChatModule/repo/ChatRepository.dart';
import 'package:mascotas_citas/Modules/ChatModule/state/ChatState.dart';
import 'package:mascotas_citas/Modules/ChatModule/usecases/GetChatsUseCase.dart';
import 'package:mascotas_citas/Modules/ChatModule/usecases/ListenToChatUpdates.dart';
import 'package:mascotas_citas/Modules/CreateUserModule/repo/CreateUserRepo.dart';
import 'package:mascotas_citas/Modules/CreateUserModule/state/CreateUserState.dart';
import 'package:mascotas_citas/Modules/CreateUserModule/usecases/CreateUserUseCase.dart';
import 'package:mascotas_citas/Modules/LikesModule/repo/LikesRepository.dart';
import 'package:mascotas_citas/Modules/LikesModule/starter.dart';
import 'package:mascotas_citas/Modules/LikesModule/state/LikeModuleState.dart';
import 'package:mascotas_citas/Modules/LikesModule/usecases/AcceptLikeUseCase.dart';
import 'package:mascotas_citas/Modules/LikesModule/usecases/GetLikesUseCase.dart';
import 'package:mascotas_citas/Modules/LikesModule/usecases/ListenToLikesUseCase.dart';
import 'package:mascotas_citas/Modules/LikesModule/usecases/RejectLikeUseCase.dart';
import 'package:mascotas_citas/Modules/LikesModule/usecases/RevealLikesUseCase.dart';
import 'package:mascotas_citas/Modules/ProfileModule/repo/SettingsRepo.dart';
import 'package:mascotas_citas/Modules/ProfileModule/state/settingsState.dart';
import 'package:mascotas_citas/Modules/ProfileModule/usecases/LogOutUseCase.dart';
import 'package:mascotas_citas/Modules/WebSocketModule/WebSocketInitUseCase.dart';
import 'package:mascotas_citas/Modules/WebSocketModule/starter.dart';
import 'package:mascotas_citas/interfaces/auth/IAuthServices.dart';
import 'package:mascotas_citas/services/ApiService.dart';
import 'package:mascotas_citas/services/WebSocketService.dart';
import 'package:mascotas_citas/services/auth/AuthSesionDataService.dart';
import 'package:mascotas_citas/services/auth/WebLoginService.dart';
import 'package:mascotas_citas/services/platform/storage/LocationManager.dart';
import 'package:mascotas_citas/services/platform/storage/SecureStorage.dart';
import 'package:mascotas_citas/startter_manager.dart';

import '../Modules/AuthenticationModule/state/AuthState.dart';

final GetIt getIt = GetIt.instance;

void setUpServices() {
  getIt.registerSingleton<SecureStorage>(SecureStorage());
  getIt.registerSingleton<AuthDataService>(
      AuthDataService(secureStorage: getIt<SecureStorage>()));
  getIt.registerSingleton<DioApiService>(
      DioApiService(authDataService: getIt<AuthDataService>()));
  getIt.registerSingleton<IAuthServices>(
      WebLoginService(apiService: getIt<DioApiService>()));
  getIt.registerSingleton<LocationManager>(LocationManager());
  getIt.registerSingleton<WebSocketService>(
      WebSocketService(authDataService: getIt<AuthDataService>()));
}

void setUpStates() {
  getIt.registerSingleton<AuthState>(AuthState());
  getIt.registerSingleton<CreateUserState>(CreateUserState());
  getIt.registerSingleton<Settingsstate>(Settingsstate());
  getIt.registerSingleton<LikeModuleState>(LikeModuleState(onErrorData: null));
  getIt.registerSingleton<ChatState>(ChatState());
}

void setUpDependencies() {
  getIt.registerSingleton<WebSocketInitUseCase>(
      WebSocketInitUseCase(webSocketService: getIt<WebSocketService>()));
  getIt.registerSingleton<LikeRepositoryImpl>(LikeRepositoryImpl(
      dioApiService: getIt<DioApiService>(),
      webSocketService: getIt<WebSocketService>()));
  getIt.registerSingleton<ChatRepository>(ChatRepositoryImpl(
      dioApiService: getIt<DioApiService>(),
      webSocketService: getIt<WebSocketService>()));

  getIt.registerSingleton<Listentolikesusecase>(Listentolikesusecase(
      likeRepository: getIt<LikeRepositoryImpl>(),
      likeModuleState: getIt<LikeModuleState>()));
  getIt.registerSingleton<GetChatsUseCase>(GetChatsUseCase(
      chatRepository: getIt<ChatRepository>(), chatState: getIt<ChatState>()));
  getIt.registerSingleton<ListenToChatUpdates>(ListenToChatUpdates(
      chatRepository: getIt<ChatRepository>(), chatState: getIt<ChatState>()));

  getIt.registerSingleton<SettingsRepo>(SettingsRepoImpl(
      authDataService: getIt<AuthDataService>(),
      apiService: getIt<DioApiService>()));
  getIt.registerSingleton<LogOutUseCase>(LogOutUseCase(
      settingsRepo: getIt<SettingsRepo>(),
      authDataService: getIt<AuthDataService>()));
  getIt.registerSingleton<AuthenticationRepo>(AuthenticationRepoImpl(
      webLoginService: getIt<IAuthServices>(),
      apiService: getIt<DioApiService>()));
  getIt.registerSingleton<CreateUserRepo>(
      CreateUserRepoImpl(apiService: getIt<DioApiService>()));
  getIt.registerSingleton<SignUpUseCase>(SignUpUseCase(
      createUserRepo: getIt<CreateUserRepo>(),
      locationManager: getIt<LocationManager>(),
      createUserState: getIt<CreateUserState>()));

  getIt.registerSingleton<GetLikesUseCase>(GetLikesUseCase(
      likeRepository: getIt<LikeRepositoryImpl>(),
      likeModuleState: getIt<LikeModuleState>()));
  getIt.registerSingleton<LogInWithGoogleUseCase>(LogInWithGoogleUseCase(
      authenticationRepo: getIt<AuthenticationRepo>(),
      authdataService: getIt<AuthDataService>(),
      authState: getIt<AuthState>()));
  getIt.registerSingleton<CheckIfUsserCanLogInUseCase>(
      CheckIfUsserCanLogInUseCase(
          authDataService: getIt<AuthDataService>(),
          authRepo: getIt<AuthenticationRepo>()));
getIt.registerSingleton<ChatModuleStarter>(ChatModuleStarter(
      useCases: [getIt<GetChatsUseCase>(), getIt<ListenToChatUpdates>()]));
  getIt.registerSingleton<WebSocketStarter>(
      WebSocketStarter(webSocketInitUseCase: getIt<WebSocketInitUseCase>()));
  getIt.registerSingleton<AcceptLikeUseCase>(AcceptLikeUseCase(
      likeModuleState: getIt<LikeModuleState>(),
      likeRepository: getIt<LikeRepositoryImpl>()));
  getIt.registerSingleton<LikeModuleStarter>(LikeModuleStarter(
      useCases: [getIt<Listentolikesusecase>(), getIt<GetLikesUseCase>()]));
  getIt.registerSingleton<RevealLikeUseCase>(RevealLikeUseCase(
      likeRepository: getIt<LikeRepositoryImpl>(),
      likeModuleState: getIt<LikeModuleState>()));
  getIt.registerSingleton<RejectLikeUseCase>(RejectLikeUseCase(
      likeRepository: getIt<LikeRepositoryImpl>(),
      likeModuleState: getIt<LikeModuleState>()));
  getIt.registerSingleton<StarterManager>(StarterManager(
      selfLoginWithGoogleUseCase: getIt<CheckIfUsserCanLogInUseCase>(),
      starters: [getIt<WebSocketStarter>(), getIt<LikeModuleStarter>(),getIt<ChatModuleStarter>()]));
}

Future<void> initAsyncDependencies() async {
  await getIt<AuthDataService>().loadAll();
}
