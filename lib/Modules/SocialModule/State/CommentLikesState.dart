import 'package:flutter/material.dart';
import 'package:mascotas_citas/Modules/SocialModule/models/CommentLikesModel.dart';
import 'package:mascotas_citas/Exceptions/ModuleException.dart';
import 'package:mascotas_citas/interfaces/state/IState.dart';

enum CommentLikesStatus {
  initial,
  loading,
  loaded,
  error,
}

class CommentLikesState extends ChangeNotifier implements ModuleState {
  List<CommentLikesModel> commentLikes = [];
  CommentLikesStatus status = CommentLikesStatus.initial;
  ModuleException? error;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initialize() {
    commentLikes = [];
    status = CommentLikesStatus.initial;
    error = null;
    notifyListeners();
  }

  @override
  void setData(data) {
    if (data is List<CommentLikesModel>) {
      commentLikes = data;
      status = CommentLikesStatus.loaded;
      notifyListeners();
    }
  }

  @override
  void setError(ModuleException e) {
    error = e;
    status = CommentLikesStatus.error;
    notifyListeners();
  }

  void setInitialState() {
    status = CommentLikesStatus.initial;
    notifyListeners();
  }

  void setLoadingState() {
    status = CommentLikesStatus.loading;
    notifyListeners();
  }

  void setLoadedState() {
    status = CommentLikesStatus.loaded;
    notifyListeners();
  }

  void setErrorState() {
    status = CommentLikesStatus.error;
    notifyListeners();
  }
}