import 'package:mascotas_citas/Modules/SocialModule/models/CommentsModel.dart';

class SocialModel {
  final String id;
  final String userUID;
  final String postUID;
  final String imageURL;
  final String description;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  List<CommentsModel> comentarios = [];

  SocialModel({
    required this.id,
    required this.userUID,
    required this.postUID,
    required this.imageURL,
    required this.description,
    required this.likesCount,
    required this.commentsCount,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    required this.comentarios,
  });

  // Factory constructor to create a SocialModel from a JSON map
 factory SocialModel.fromJson(Map<String, dynamic> json) {
  return SocialModel(
    id: json['id']?.toString() ?? '',
    userUID: json['userUID']?.toString() ?? '',
    postUID: json['postUID']?.toString() ?? '',
    imageURL: json['imageURL']?.toString() ?? '',
    description: json['description']?.toString() ?? '',
    likesCount: json['likesCount'] is int
        ? json['likesCount'] as int
        : int.tryParse(json['likesCount']?.toString() ?? '0') ?? 0,
    commentsCount: json['commentsCount'] is int
        ? json['commentsCount'] as int
        : int.tryParse(json['commentsCount']?.toString() ?? '0') ?? 0,
    createdAt: json['created_at'] != null
        ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
        : DateTime.now(),
    updatedAt: json['updated_at'] != null
        ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
        : DateTime.now(),
    version: json['version'] is int
        ? json['version'] as int
        : int.tryParse(json['version']?.toString() ?? '0') ?? 0,
    comentarios: (json['comentarios'] as List<dynamic>?)
            ?.map((comment) => CommentsModel.fromJson(comment as Map<String, dynamic>))
            .toList() ??
        [],
  );
}

  // Method to convert a SocialModel instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userUID': userUID,
      'postUID': postUID,
      'imageURL': imageURL,
      'description': description,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'version': version,
      'comentarios': comentarios.map((comment) => comment.toJson()).toList(),
    };
  }
}