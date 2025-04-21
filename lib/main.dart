import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mascotas_citas/Modules/AuthenticationModule/usecases/LogInWithGoogleUseCase.dart';
import 'package:mascotas_citas/Modules/AuthenticationModule/views/AuthScreen.dart';
import 'package:mascotas_citas/Modules/CreateUserModule/views/CreateUserScreen.dart';
import 'package:mascotas_citas/navigation_controller.dart';
import 'package:mascotas_citas/dependencies/injector.dart';
import 'package:provider/provider.dart';
import 'package:mascotas_citas/splash_screen.dart';
import 'package:mascotas_citas/Modules/HomeModule/State/mascota_provider.dart';
import 'package:mascotas_citas/Modules/SocialModule/State/social_provider.dart';
import 'package:mascotas_citas/Modules/AuthenticationModule/state/AuthState.dart';
import 'package:mascotas_citas/Resources/providers/theme_provider.dart'; // Importa el ThemeProvider

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setUpServices();
  setUpStates();
  setUpDependencies();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthState()),
        ChangeNotifierProvider(create: (context) => MascotaProvider()),
        ChangeNotifierProvider(create: (context) => SocialProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()), // Agregar ThemeProvider
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
                  ? themeProvider.themeData // Tema oscuro del provider
                  : ThemeData(
                      primarySwatch: Colors.pink,
                      visualDensity: VisualDensity.adaptivePlatformDensity,
                      scaffoldBackgroundColor: Color.fromRGBO(242, 217, 208, 1),
                      appBarTheme: AppBarTheme(
                        backgroundColor: Color.fromRGBO(242, 217, 208, 1),
                        foregroundColor: Colors.black,
                      ),
                    ),
                // Modificar cómo se definen las rutas para mantener el contexto de los providers
                home: const SplashScreen(),
                onGenerateRoute: (settings) {
                  switch (settings.name) {
                    case '/splash':
                      return MaterialPageRoute(builder: (_) => const SplashScreen());
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