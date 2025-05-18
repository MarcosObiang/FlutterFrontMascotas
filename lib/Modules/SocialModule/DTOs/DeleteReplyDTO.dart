class DeleteReplyDTO {
  String replyUID;
  String commentUID;

  DeleteReplyDTO({
    required this.replyUID,
    required this.commentUID,
  });

  factory DeleteReplyDTO.fromJson(Map<String, dynamic> json) {
    return DeleteReplyDTO(
      replyUID: json['replyUID'] as String,
      commentUID: json['commentUID'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'replyUID': replyUID,
      'commentUID': commentUID,
    };
  }
}