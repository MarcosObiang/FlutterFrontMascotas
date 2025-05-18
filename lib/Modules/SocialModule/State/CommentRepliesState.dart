import 'package:flutter/material.dart';
import 'package:mascotas_citas/Modules/SocialModule/models/CommentRepliesModel.dart';
import 'package:mascotas_citas/Exceptions/ModuleException.dart';
import 'package:mascotas_citas/interfaces/state/IState.dart';

enum CommentRepliesStatus {
  initial,
  loading,
  loaded,
  error,
}

class CommentRepliesState extends ChangeNotifier implements ModuleState {
  List<CommentRepliesModel> replies = [];
  CommentRepliesStatus status = CommentRepliesStatus.initial;
  ModuleException? error;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initialize() {
    replies = [];
    status = CommentRepliesStatus.initial;
    error = null;
    notifyListeners();
  }

  @override
  void setData(data) {
    if (data is List<CommentRepliesModel>) {
      replies = data;
      status = CommentRepliesStatus.loaded;
      notifyListeners();
    }
  }

  @override
  void setError(ModuleException e) {
    error = e;
    status = CommentRepliesStatus.error;
    notifyListeners();
  }

  void setInitialState() {
    status = CommentRepliesStatus.initial;
    notifyListeners();
  }

  void setLoadingState() {
    status = CommentRepliesStatus.loading;
    notifyListeners();
  }

  void setLoadedState() {
    status = CommentRepliesStatus.loaded;
    notifyListeners();
  }

  void setErrorState() {
    status = CommentRepliesStatus.error;
    notifyListeners();
  }
}