import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mascotas_citas/Modules/Authentication/usecases/LogInWithGoogleUseCase.dart';
import 'package:mascotas_citas/Modules/Authentication/views/AuthScreen.dart';
import 'package:mascotas_citas/dependencies/injector.dart';
import 'package:provider/provider.dart';

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
            // Define routes for navigation
            routes: {
              '/authScreen': (context) => Authscreen(), // MyWidget screen
            },
            initialRoute: '/authScreen', // Start with the home screen
          );
        });
  }
}
