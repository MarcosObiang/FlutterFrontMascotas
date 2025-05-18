class CommentLikesModel {
  final String commentUID;
  final String userUID;
  final DateTime? date;

  CommentLikesModel({
    required this.commentUID,
    required this.userUID,
    this.date,
  });

  factory CommentLikesModel.fromJson(Map<String, dynamic> json) {
    return CommentLikesModel(
      commentUID: json['commentUID'] as String,
      userUID: json['userUID'] as String,
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'commentUID': commentUID,
      'userUID': userUID,
      'date': date?.toIso8601String(),
    };
  }
}