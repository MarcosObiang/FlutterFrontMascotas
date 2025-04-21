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
    if (logInWithGoogleUseCase.authState.getAuthStatus == AuthStatus.success || logInWithGoogleUseCase.authState.getAuthStatus == AuthStatus.error) {
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