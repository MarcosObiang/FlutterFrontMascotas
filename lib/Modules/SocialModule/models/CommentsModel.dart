class CommentsModel {
  final String id;
  final String commentUID;
  final String postUID;
  final String userUID;
  final String? commentText;
  final int likesCount;
  final int repliesCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CommentsModel({
    required this.id,
    required this.commentUID,
    required this.postUID,
    required this.userUID,
    this.commentText,
    this.likesCount = 0,
    this.repliesCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory CommentsModel.fromJson(Map<String, dynamic> json) {
    return CommentsModel(
      id: json['id'] as String,
      commentUID: json['commentUID'] as String,
      postUID: json['postUID'] as String,
      userUID: json['userUID'] as String,
      commentText: json['commentText'] as String?,
      likesCount: json['likesCount'] as int? ?? 0,
      repliesCount: json['repliesCount'] as int? ?? 0,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'commentUID': commentUID,
      'postUID': postUID,
      'userUID': userUID,
      'commentText': commentText,
      'likesCount': likesCount,
      'repliesCount': repliesCount,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}