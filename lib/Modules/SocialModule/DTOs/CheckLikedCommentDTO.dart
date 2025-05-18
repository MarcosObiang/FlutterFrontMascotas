class CheckLikedCommentDTO {
  String commentUID;
  String userUID;

  CheckLikedCommentDTO({
    required this.commentUID,
    required this.userUID,
  });

  factory CheckLikedCommentDTO.fromJson(Map<String, dynamic> json) {
    return CheckLikedCommentDTO(
      commentUID: json['commentUID'] as String,
      userUID: json['userUID'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'commentUID': commentUID,
      'userUID': userUID,
    };
  }
}