import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mascotas_citas/Exceptions/ModuleException.dart';
import 'package:mascotas_citas/Modules/LikesModule/model/LikeModel.dart';
import 'package:mascotas_citas/services/ApiService.dart';
import 'package:mascotas_citas/services/WebSocketService.dart';

abstract class LikeRepository {
  Future<List<LikeModel>> getAllLikes();
  Future<void> rejectLike(String likeUID);
  Future<void> acceptLike(String likeUID);
  Future<void> revealReaction(LikeModel likeModel);
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
  Future<List<LikeModel>> getAllLikes() async {
    try {
      final result = await dioApiService
          .get(path: "/likes-service/likes/get", queryParams: {});
      if (result.statusCode == 200) {
        List<dynamic> data = result.data;
        List<LikeModel> likes = data.map((e) => LikeModel.fromJson(e)).toList();
        return likes;
      }
      return [];
    } on Exception catch (e) {
      if (e is DioException) {
       throw ModuleException(
            message: "Error al obtener los likes ",
            title: "Error - ${e.response?.statusCode}");
      } throw ModuleException(
            message: "Error al obtener los likes ",
            title: "Error - ${e.toString()}");
      }
      // TODO
    }
  

  @override
  Future<void> rejectLike(String likeUID) async {
    try {
      final result = await dioApiService.delete(
          path: "/likes-service/likes/delete/$likeUID",
          data: {"likeUID": likeUID});
      if (result.statusCode == 200) {
        return Future.value(null);
      } else {
        Logger().e(result);
      }
    } on Exception catch (e) {
      if (e is DioException) {
       throw ModuleException(
            message: "Error al rechazar el like ",
            title: "Error - ${e.response?.statusCode}");
      } else {
        throw ModuleException(
            message: "Error al rechazar el like ",
            title: "Error - ${e.toString()}");
      }
    }
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
          .map((event) => LikeModel.fromJson(event["data"]));

  @override
  Future<void> revealReaction(LikeModel likeModel) async {
    try {
      final result = await dioApiService.post(
          path: "/orquestador/api/reveal-like", data: likeModel.toJson());
      if (result.statusCode == 200) {
        return Future.value(null);
      } else {
        Logger().e(result);
      }
    } on Exception catch (e) {
      if (e is DioException) {
        throw ModuleException(
            message: "Error al revelar el like ",
            title: "Error - ${e.response?.statusCode}");
      } else {
        ModuleException(
            message: "Error al revelar el like ",
            title: "Error - ${e.toString()}");
      }
    }
  }
}
