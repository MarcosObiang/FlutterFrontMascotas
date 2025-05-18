class CheckLikedRequestDTO {
  String postUID;
  String userUID;

  CheckLikedRequestDTO({
    required this.postUID,
    required this.userUID,
  });

  factory CheckLikedRequestDTO.fromJson(Map<String, dynamic> json) {
    return CheckLikedRequestDTO(
      postUID: json['postUID'] as String,
      userUID: json['userUID'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postUID': postUID,
      'userUID': userUID,
    };
  }
}