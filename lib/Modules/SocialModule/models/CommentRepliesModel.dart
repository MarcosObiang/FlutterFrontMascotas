class CommentRepliesModel {
  final String id;
  final String commentUID;
  final String userUID;
  final String replyUID;
  final String replyText;
  final DateTime? createdDate;
  final DateTime? updatedDate;

  CommentRepliesModel({
    required this.id,
    required this.commentUID,
    required this.userUID,
    required this.replyUID,
    required this.replyText,
    this.createdDate,
    this.updatedDate,
  });

  factory CommentRepliesModel.fromJson(Map<String, dynamic> json) {
    return CommentRepliesModel(
      id: json['id'] as String,
      commentUID: json['commentUID'] as String,
      userUID: json['userUID'] as String,
      replyUID: json['replyUID'] as String,
      replyText: json['replyText'] as String,
      createdDate: json['createdDate'] != null ? DateTime.parse(json['createdDate']) : null,
      updatedDate: json['updatedDate'] != null ? DateTime.parse(json['updatedDate']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'commentUID': commentUID,
      'userUID': userUID,
      'replyUID': replyUID,
      'replyText': replyText,
      'createdDate': createdDate?.toIso8601String(),
      'updatedDate': updatedDate?.toIso8601String(),
    };
  }
}