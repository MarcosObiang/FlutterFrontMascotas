import 'package:flutter/cupertino.dart';
import 'package:mascotas_citas/Exceptions/ModuleException.dart';
import 'package:mascotas_citas/Modules/SocialModule/models/CommentsModel.dart';
import 'package:mascotas_citas/Modules/SocialModule/models/SocialModel.dart';
import 'package:mascotas_citas/interfaces/state/IState.dart';

enum SocialStatus {
  initial,
  loading,
  loaded,
  error,
}

class SocialState extends ChangeNotifier implements ModuleState {
  List<SocialModel> posts = [];
  SocialStatus state = SocialStatus.initial;
  ModuleException? error;



  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initialize() {
    posts = [];
    state = SocialStatus.initial;
    error = null;
    notifyListeners();
  }

  @override
  void setData(data) {
    if (data is List<SocialModel>) {
      posts = data;
      state = SocialStatus.loaded;
      notifyListeners();
    }
  }

  @override
  void setError(ModuleException e) {
    error = e;
    state = SocialStatus.error;
    notifyListeners();
  }

  void setInitialState() {
    state = SocialStatus.initial;
    notifyListeners();
  }

  void setLoadingState() {
    state = SocialStatus.loading;
    notifyListeners();
  }

  void setLoadedState() {
    state = SocialStatus.loaded;
    notifyListeners();
  }

  void setErrorState() {
    state = SocialStatus.error;
    notifyListeners();
  }
}