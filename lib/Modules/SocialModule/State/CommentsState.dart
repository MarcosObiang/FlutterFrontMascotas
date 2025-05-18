import 'package:flutter/material.dart';
import 'package:mascotas_citas/Modules/SocialModule/models/CommentsModel.dart';
import 'package:mascotas_citas/Exceptions/ModuleException.dart';
import 'package:mascotas_citas/interfaces/state/IState.dart';

enum CommentsStatus {
  initial,
  loading,
  loaded,
  error,
}

class CommentsState extends ChangeNotifier implements ModuleState {
  List<CommentsModel> comments = [];
  CommentsStatus status = CommentsStatus.initial;
  ModuleException? error;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initialize() {
    comments = [];
    status = CommentsStatus.initial;
    error = null;
    notifyListeners();
  }

  @override
  void setData(data) {
    if (data is List<CommentsModel>) {
      comments = data;
      status = CommentsStatus.loaded;
      notifyListeners();
    }
  }

  @override
  void setError(ModuleException e) {
    error = e;
    status = CommentsStatus.error;
    notifyListeners();
  }

  void setInitialState() {
    status = CommentsStatus.initial;
    notifyListeners();
  }

  void setLoadingState() {
    status = CommentsStatus.loading;
    notifyListeners();
  }

  void setLoadedState() {
    status = CommentsStatus.loaded;
    notifyListeners();
  }

  void setErrorState() {
    status = CommentsStatus.error;
    notifyListeners();
  }
}