import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mascotas_citas/Dialogs/PresentationDialogs.dart';
import 'package:mascotas_citas/Modules/AuthenticationModule/state/AuthState.dart';
import 'package:mascotas_citas/Modules/AuthenticationModule/usecases/LogInWithGoogleUseCase.dart';
import 'package:mascotas_citas/dependencies/injector.dart';
import 'package:mascotas_citas/types/callbacks.dart';
import 'package:provider/provider.dart';
import 'package:mascotas_citas/navigation_controller.dart';

class Authscreen extends StatefulWidget {
  const Authscreen({super.key});

  @override
  State<Authscreen> createState() {
    return _AuthscreenState();
  }
}

class _AuthscreenState extends State<Authscreen> {
  LogInWithGoogleUseCase logInWithGoogleUseCase =
      getIt<LogInWithGoogleUseCase>();
      
  @override
  void initState() {
    super.initState();
    
    // Agregamos un listener para detectar cambios en el estado de autenticación
    logInWithGoogleUseCase.authState.addListener(_onAuthStateChanged);
  }

  @override
  void dispose() {
    // Removemos el listener cuando se destruye el widget
    logInWithGoogleUseCase.authState.removeListener(_onAuthStateChanged);
    super.dispose();
  }

  // Esta función se ejecutará cada vez que cambie el estado de autenticación
  void _onAuthStateChanged() {
    // Si el usuario está autenticado (estado success), navegamos a la pantalla home
    if (logInWithGoogleUseCase.authState.getAuthStatus == AuthStatus.success) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const NavigationController()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: logInWithGoogleUseCase.authState,
      child: Consumer<AuthState>(
        builder: (BuildContext context, AuthState authState, Widget? child) {
          authState.onError = ({required String title, required String message}) {
            PresentationDialogs().showErrorDialog(
                title: title, content: message, context: context);
          };
          
          return Scaffold(
            backgroundColor: const Color.fromRGBO(242, 217, 208, 1),
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(18.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Center(
                        child: Image.asset(
                          'assets/logos/logo_wildlove_nombre.png',
                          width: 1000.w,
                          height: 1000.h,
                        ),
                      ),
                    ),
                    authState.getAuthStatus == AuthStatus.loading
                        ? Center(child: CircularProgressIndicator())
                        : _buildGoogleButton(authState),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGoogleButton(AuthState authState) {
    return ElevatedButton(
      onPressed: () async {
        try {
          // Ejecutamos el caso de uso de login con Google
          await logInWithGoogleUseCase.execute();
          // No necesitamos navegar aquí, el listener se encargará de hacerlo
          // cuando el estado de autenticación cambie a "success"
        } catch (e) {
          // Manejamos cualquier error que ocurra durante la autenticación
          PresentationDialogs().showErrorDialog(
            title: "Error de autenticación", 
            content: e.toString(), 
            context: context
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        padding: EdgeInsets.symmetric(vertical: 15.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/logos/google_logo.svg',
            width: 50.w,
            height: 50.h,
          ),
          SizedBox(width: 12.w),
          Text(
            'Continuar con Google',
            style: TextStyle(
              fontSize: 50.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}