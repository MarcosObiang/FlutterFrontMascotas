import 'package:flutter/material.dart';
import 'package:mascotas_citas/Exceptions/ModuleException.dart';
import 'package:mascotas_citas/interfaces/state/IState.dart';
import 'package:mascotas_citas/types/callbacks.dart';

enum CreateUserStatus {
  loading,
  success,
  error,
  initial,
}

class CreateUserState extends ChangeNotifier implements ModuleState {
  CreateUserStatus _status = CreateUserStatus.initial;
  String errorMessage = "";
  onErrorCallBack? onError;

  @override
  void initialize() {
    _status = CreateUserStatus.initial;
    notifyListeners();
  }

  void setCreateUserStatusSuccess() {
    _status = CreateUserStatus.success;
    notifyListeners();
  }

  void setCreateUserErrorStatus() {
    _status = CreateUserStatus.error;
    notifyListeners();
  }

  void setCreateUserLoadingStatus() {
    _status = CreateUserStatus.loading;
    notifyListeners();
  }

  @override
  void setData(data) {
    // TODO: implement setData
  }


  CreateUserStatus get getCreateUserStatus => _status;

  @override
  void setError(ModuleException e) {
    errorMessage = e.message;
    setCreateUserErrorStatus();
    onError?.call(title: e.title, message: e.message);
  }
}
