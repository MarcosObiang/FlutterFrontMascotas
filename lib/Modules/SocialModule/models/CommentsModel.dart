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
    id: json['id']?.toString() ?? '',
    commentUID: json['commentUID']?.toString() ?? '',
    postUID: json['postUID']?.toString() ?? '',
    userUID: json['userUID']?.toString() ?? '',
    commentText: json['commentText']?.toString(),
    likesCount: json['likesCount'] is int
        ? json['likesCount'] as int
        : int.tryParse(json['likesCount']?.toString() ?? '0') ?? 0,
    repliesCount: json['repliesCount'] is int
        ? json['repliesCount'] as int
        : int.tryParse(json['repliesCount']?.toString() ?? '0') ?? 0,
    createdAt: json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'].toString())
        : null,
    updatedAt: json['updatedAt'] != null
        ? DateTime.tryParse(json['updatedAt'].toString())
        : null,
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