import 'package:flutter/material.dart';
import 'package:mascotas_citas/Exceptions/ModuleException.dart';
import 'package:mascotas_citas/Modules/ProfileModule/model/PetSettingsModel.dart';
import 'package:mascotas_citas/Modules/ProfileModule/model/ProfileSettings.dart';
import 'package:mascotas_citas/interfaces/state/IState.dart';
import 'package:mascotas_citas/types/callbacks.dart';

enum Status {
  initial,
  loading,
  loaded,
  error,
}

enum UpdateProfilePictureStatus { updating, error, loaded, initial }

enum UpdateProfileBioStatus { updating, error, loaded, initial }

class SettingsState extends ChangeNotifier implements ModuleState {
  ProfileSettings? data;
  List<PetSettingsModel>? pets = List.empty(growable: true);
  ProfileSettings? cacheData;
  List<PetSettingsModel>? cachePets = List.empty(growable: true);

  Status state = Status.initial;
  UpdateProfilePictureStatus updateProfilePictureStatus =
      UpdateProfilePictureStatus.loaded;

  UpdateProfileBioStatus updateProfileBioStatus = UpdateProfileBioStatus.loaded;

  onErrorCallBack? onError;

  void setStateInitial() {
    state = Status.initial;
    notifyListeners();
  }

  void setStateLoading() {
    state = Status.loading;
    notifyListeners();
  }

  void setStateLoaded() {
    state = Status.loaded;
    notifyListeners();
  }

  void setStateError() {
    state = Status.error;
    notifyListeners();
  }

  void setUpdateProfilePictureStatusUpdating(
      UpdateProfilePictureStatus status) {
    updateProfilePictureStatus = status;

    WidgetsBinding.instance.scheduleFrameCallback((_) {
      notifyListeners();
    });
  }

  void setUpdateProfileBioStatusUpdating(UpdateProfileBioStatus status) {
    updateProfileBioStatus = status;
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
    if (data is ProfileSettings) {
      this.data = data;
    }
    if (data is List<PetSettingsModel>) {
      this.pets = data;
    }
    state = Status.loaded;
    notifyListeners();
  }

  @override
  void setError(ModuleException e) {
    state = Status.error;
    notifyListeners();
  }
}
