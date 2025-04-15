import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mascotas_citas/Dialogs/PresentationDialogs.dart';
import 'package:mascotas_citas/Modules/Authentication/state/AuthState.dart';
import 'package:mascotas_citas/Modules/Authentication/usecases/LogInWithGoogleUseCase.dart';
import 'package:mascotas_citas/dependencies/injector.dart';
import 'package:mascotas_citas/types/callbacks.dart';
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
        await logInWithGoogleUseCase.execute();
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