import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mascotas_citas/Dialogs/PresentationDialogs.dart';
import 'package:mascotas_citas/Modules/AuthenticationModule/state/AuthState.dart';
import 'package:mascotas_citas/Modules/AuthenticationModule/usecases/LogInWithGoogleUseCase.dart';
import 'package:mascotas_citas/dependencies/injector.dart';
import 'package:provider/provider.dart';

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
        Navigator.pushNamed(context, '/navigation');
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
          
          return Container(
            color: const Color.fromRGBO(242, 217, 208, 1),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo de WildLove
                  Image.asset(
                    'assets/logos/logo_wildlove_nombre.png',
                    width: 1000.w,
                    height: 1000.h,
                  ),
                  SizedBox(height: 300.h),
                  // Botón de Google o indicador de carga
                  Center(
                    child: authState.getAuthStatus == AuthStatus.loading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () async {
                            try {
                              // Ejecutamos el caso de uso de login con Google
                              await logInWithGoogleUseCase.execute().then((value){
                            if(value){
                              print("El usuario ya está registrado");
                            }
                            else{
                              print("El usuario no está registrado");

                            }
                          }); 


                              // El listener se encargará de la navegación
                            } catch (e) {
                              // Manejamos cualquier error
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          child: SizedBox(
                            width: 600.w,
                            height: 100.h,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  "Iniciar con Google",
                                  style: TextStyle(
                                    fontSize: 50.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SvgPicture.asset(
                                  'assets/logos/google_logo.svg',
                                  width: 60.w,
                                  height: 60.h,
                                  fit: BoxFit.contain,
                                  alignment: Alignment.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}