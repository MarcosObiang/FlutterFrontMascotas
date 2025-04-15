import 'package:flutter/material.dart';
import 'package:mascotas_citas/Exceptions/ModuleException.dart';
import 'package:mascotas_citas/Modules/AuthenticationModule/DTOs/LogInDTO.dart';
import 'package:mascotas_citas/interfaces/state/IState.dart';
import 'package:mascotas_citas/types/callbacks.dart';

import '../../../interfaces/state/UpdateableModuleState.dart';

enum AuthStatus {
  loading,
  success,
  error,
  initial,
}





class AuthState extends ChangeNotifier implements ModuleState<LoginDTO> {
  late AuthStatus _authStatus = AuthStatus.initial;
  String errorMessage = "";
  onErrorCallBack? onError;

  @override
  void initialize() {
    _authStatus = AuthStatus.initial;
    notifyListeners();
  }

  void setAuthStateUserLogged() {
    _authStatus = AuthStatus.success;
    notifyListeners();
  }

  void setAuthStateErrorLogin() {
    _authStatus = AuthStatus.error;
    notifyListeners();
  }

  void setAuthStateLoading() {
    _authStatus = AuthStatus.loading;
    notifyListeners();
  }

  AuthStatus get getAuthStatus => _authStatus;
  

  @override
  void setData(LoginDTO data) {
    // TODO: implement setData
  }

  @override
  void setError(ModuleException e) {
    errorMessage = e.message;
    setAuthStateErrorLogin();
    onError?.call(title:e.title, message: e.content);
  }
}
