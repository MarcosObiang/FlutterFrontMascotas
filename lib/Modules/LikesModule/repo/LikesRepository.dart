import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mascotas_citas/Modules/LikesModule/model/LikeModel.dart';
import 'package:mascotas_citas/services/ApiService.dart';
import 'package:mascotas_citas/services/WebSocketService.dart';

abstract class LikeRepository {
  Future<void> getAllLikes();
  Future<void> rejectLike(String likeUID);
  Future<void> acceptLike(String likeUID);
  Stream<LikeModel> get onMessageReceived;
}

class LikeRepositoryImpl implements LikeRepository {
  DioApiService dioApiService;
  WebSocketService webSocketService;
  LikeRepositoryImpl(
      {required this.dioApiService, required this.webSocketService});

  @override
  Future<void> acceptLike(String likeUID) {
    // TODO: implement acceptLike
    throw UnimplementedError();
  }

  @override
  Future<void> getAllLikes() {
    // TODO: implement getAllLikes
    throw UnimplementedError();
  }

  @override
  Future<void> rejectLike(String likeUID) {
    // TODO: implement rejectLike
    throw UnimplementedError();
  }

  Future<void> transformStream() async {
    webSocketService.onMessageReceived.stream.listen((event) {
      print(event);
    });
  }

  @override
  Stream<LikeModel> get onMessageReceived =>
      webSocketService.onMessageReceived.stream
          .where((data) => data["dataType"] == "like")
          .map((event) => LikeModel.fromJson(jsonDecode(event["data"])));
}
