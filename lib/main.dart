import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mascotas_citas/Modules/AuthenticationModule/views/AuthScreen.dart';
import 'package:mascotas_citas/Modules/ChatModule/state/ChatState.dart';
import 'package:mascotas_citas/Modules/CreateUserModule/state/CreateUserState.dart';
import 'package:mascotas_citas/Modules/CreateUserModule/views/CreateUserScreen.dart';
import 'package:mascotas_citas/Modules/LikesModule/state/LikeModuleState.dart';
import 'package:mascotas_citas/Modules/ProfileModule/ViewModels/perfil_view_model.dart';
import 'package:mascotas_citas/Modules/SocialModule/dependencies/socialInjector.dart';
import 'package:mascotas_citas/Modules/MessagesModule/state/MessagesState.dart';
import 'package:mascotas_citas/navigation_controller.dart';
import 'package:mascotas_citas/dependencies/injector.dart';
import 'package:mascotas_citas/services/ApiServiceRD.dart';
import 'package:mascotas_citas/services/auth/AuthSesionDataService.dart';
import 'package:mascotas_citas/services/platform/storage/SecureStorage.dart';
import 'package:provider/provider.dart';
import 'package:mascotas_citas/splash_screen.dart';
import 'package:mascotas_citas/Modules/HomeModule/State/mascota_provider.dart';
import 'package:mascotas_citas/Modules/SocialModule/State/social_provider.dart';
import 'package:mascotas_citas/Modules/AuthenticationModule/state/AuthState.dart';
import 'package:mascotas_citas/Resources/providers/theme_provider.dart';
import 'package:mascotas_citas/Modules/ProfileModule/component/configuracion_busqueda_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setUpServices();
  setUpStates();
  setUpDependencies();
  setUpSocialDependencies();
  await initAsyncDependencies();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Estados principales
        ChangeNotifierProvider(create: (context) => AuthState()),
        ChangeNotifierProvider(create: (context) => MascotaProvider()),
        ChangeNotifierProvider(create: (context) => CreateUserState()),
        ChangeNotifierProvider(create: (context) => ChatState()),
        ChangeNotifierProvider(create: (context) => MessagesState()),
        ChangeNotifierProvider(create: (context) => ConfiguracionBusquedaProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => LikeModuleState(onErrorData: null)),
        // SocialProvider con dependencias por getIt
        ChangeNotifierProvider(
          create: (context) => SocialProvider(
            checkCommentLikedUseCase: getIt(),
            checkLikedUseCase: getIt(),
            createCommentLikeUseCase: getIt(),
            createCommentReplyUseCase: getIt(),
            createCommentUseCase: getIt(),
            createLikeUseCase: getIt(),
            createPostUseCase: getIt(),
            deleteCommentLikeUseCase: getIt(),
            deleteCommentReplyUseCase: getIt(),
            deleteCommentUseCase: getIt(),
            deleteLikeUseCase: getIt(),
            deletePostUseCase: getIt(),
            getAllPostUseCase: getIt(),
            getCommentsByPostUseCase: getIt(),
            getRepliesByCommentUseCase: getIt(),
            updateCommentReplyUseCase: getIt(),
            updateCommentUseCase: getIt(),
            updatePostUseCase: getIt(),
          ),
        ),

        // 🔽 Orden correcto de servicios
        Provider<SecureStorage>(create: (_) => SecureStorage()),

        Provider<AuthDataService>(
          create: (context) => AuthDataService(
            secureStorage: Provider.of<SecureStorage>(context, listen: false),
          ),
        ),

        Provider<ApiService>(
          create: (context) => ApiService(
            authDataService: Provider.of<AuthDataService>(context, listen: false),
          ),
        ),

        ChangeNotifierProvider<PerfilViewModel>(
          create: (context) => PerfilViewModel(
            // apiService: Provider.of<ApiService>(context, listen: false),
            // authDataService: Provider.of<AuthDataService>(context, listen: false),
          ),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(1080, 1920),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, child) {
          return Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'WildLove',
                theme: themeProvider.isDarkMode
                    ? themeProvider.darkTheme
                    : ThemeData(
                        primarySwatch: Colors.pink,
                        visualDensity: VisualDensity.adaptivePlatformDensity,
                        scaffoldBackgroundColor: const Color.fromRGBO(242, 217, 208, 1),
                        appBarTheme: const AppBarTheme(
                          backgroundColor: Color.fromRGBO(242, 217, 208, 1),
                          foregroundColor: Colors.black,
                        ),
                      ),
                home: const SplashScreen(),
                onGenerateRoute: (settings) {
                  switch (settings.name) {
                    case '/splash':
                      return MaterialPageRoute(builder: (_) => const SplashScreen());
                    case '/createUserScreen':
                      return MaterialPageRoute(builder: (_) => const Createuserscreen());
                    case '/authScreen':
                      return MaterialPageRoute(builder: (_) => Authscreen());
                    case '/navigation':
                      return MaterialPageRoute(builder: (_) => const NavigationController());
                    default:
                      return MaterialPageRoute(builder: (_) => const SplashScreen());
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
