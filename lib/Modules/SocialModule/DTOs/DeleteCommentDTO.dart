class DeleteCommentDTO {
  String commentUID;
  String postUID;

  DeleteCommentDTO({
    required this.commentUID,
    required this.postUID,
  });

  factory DeleteCommentDTO.fromJson(Map<String, dynamic> json) {
    return DeleteCommentDTO(
      commentUID: json['commentUID'] as String,
      postUID: json['postUID'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'commentUID': commentUID,
      'postUID': postUID,
    };
  }
}