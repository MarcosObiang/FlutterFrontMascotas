import 'package:flutter/material.dart';
import 'package:mascotas_citas/Exceptions/ModuleException.dart';
import 'package:mascotas_citas/interfaces/state/IState.dart';
import 'package:mascotas_citas/types/callbacks.dart';

enum SettingsState {
  initial,
  loading,
  loaded,
  error,
}

class Settingsstate extends ChangeNotifier implements ModuleState {
  SettingsState state = SettingsState.initial;

  onErrorCallBack? onError;

  void setStateInitial() {
    state = SettingsState.initial;
    notifyListeners();
  }

  void setStateLoading() {
    state = SettingsState.loading;
    notifyListeners();
  }

  void setStateLoaded() {
    state = SettingsState.loaded;
    notifyListeners();
  }

  void setStateError() {
    state = SettingsState.error;
    notifyListeners();
  }

  @override
  void dispose() {
    // TODO: implement dispose
  }

  @override
  void initialize() {}

  @override
  void setData(data) {
    // TODO: implement setData
  }

  @override
  void setError(ModuleException e) {
    state = SettingsState.error;
    onError?.call(message: e.message, title: e.title);
    notifyListeners();
  }
}
