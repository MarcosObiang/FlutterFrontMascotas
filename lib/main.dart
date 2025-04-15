import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mascotas_citas/Modules/Authentication/usecases/LogInWithGoogleUseCase.dart';
import 'package:mascotas_citas/Modules/Authentication/views/AuthScreen.dart';
import 'package:mascotas_citas/dependencies/injector.dart';
import 'package:provider/provider.dart';
import 'package:mascotas_citas/splash_screen.dart'; // Importamos el SplashScreen

import 'Modules/Authentication/state/AuthState.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setUpServices();
  setUpStates();
  setUpDependencies();
  runApp(MultiProvider(
    providers: [
      Provider(create: (context) => AuthState),
    ],
    child: const MainApp(),
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(1080, 1920),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'WildLove',
            // Define routes for navigation
            routes: {
              '/splash': (context) => const SplashScreen(), // SplashScreen
              '/authScreen': (context) => Authscreen(), // AuthScreen
            },
            initialRoute: '/splash', // Iniciar con el SplashScreen
          );
        });
  }
}