import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mascotas_citas/Dialogs/PresentationDialogs.dart';
import 'package:mascotas_citas/Modules/AuthenticationModule/state/AuthState.dart';
import 'package:mascotas_citas/Modules/AuthenticationModule/usecases/LogInWithGoogleUseCase.dart';
import 'package:mascotas_citas/dependencies/injector.dart';
import 'package:provider/provider.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

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
                            await logInWithGoogleUseCase.execute().then((value) {
                              if (value) {
                                Navigator.pushNamed(context, "/navigation");
                              } else {
                                Navigator.pushNamed(context, "/createUserScreen");
                              }
                            });
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