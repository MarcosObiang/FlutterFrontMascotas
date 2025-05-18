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
  });

  // Factory constructor to create a SocialModel from a JSON map
  factory SocialModel.fromJson(Map<String, dynamic> json) {
    return SocialModel(
      id: json['id'] as String,
      userUID: json['userUID'] as String,
      postUID: json['postUID'] as String,
      imageURL: json['imageURL'] as String,
      description: json['description'] as String,
      likesCount: json['likesCount'] as int,
      commentsCount: json['commentsCount'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      version: json['version'] as int,
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
    };
  }
}