import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mascotas_citas/Dialogs/PresentationDialogs.dart';
import 'package:mascotas_citas/Modules/AuthenticationModule/state/AuthState.dart';
import 'package:mascotas_citas/Modules/AuthenticationModule/usecases/LogInWithGoogleUseCase.dart';
import 'package:mascotas_citas/dependencies/injector.dart';
import 'package:mascotas_citas/types/callbacks.dart';
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
            color: Colors.white,
            child: Center(
                child: authState.getAuthStatus == AuthStatus.loading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () async {
                          await logInWithGoogleUseCase.execute();
                        },
                        child: SizedBox(
                          width: 600.w,
                          height: 100.h,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text("Iniciar con google"),
                              SvgPicture.asset(
                                  width: 60.w,
                                  height: 60.h,
                                  fit: BoxFit.contain,
                                  alignment: Alignment.center,
                                  'assets/logos/google_logo.svg'),
                            ],
                          ),
                        ))));
      }),
    );
  }
}
