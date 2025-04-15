import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mascotas_citas/Modules/AuthenticationModule/usecases/LogInWithGoogleUseCase.dart';
import 'package:mascotas_citas/Modules/AuthenticationModule/views/AuthScreen.dart';
import 'package:mascotas_citas/Modules/CreateUserModule/views/CreateUserScreen.dart';
import 'package:mascotas_citas/dependencies/injector.dart';
import 'package:provider/provider.dart';

import 'Modules/AuthenticationModule/state/AuthState.dart';

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
          return SafeArea(
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              // Define routes for navigation
              routes: {
                '/authScreen': (context) => Authscreen(),
                '/createUserScreen': (context) =>
                    Createuserscreen() // MyWidget screen
              },
              initialRoute: '/authScreen', // Start with the home screen
            ),
          );
        });
  }
}
