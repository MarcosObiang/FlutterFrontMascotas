class LikesModel {
  final String id;
  final String postUID;
  final String userUID;
  final DateTime date;

  LikesModel({
    required this.id,
    required this.postUID,
    required this.userUID,
    required this.date,
  });

  factory LikesModel.fromJson(Map<String, dynamic> json) {
    return LikesModel(
      id: json['id'] as String,
      postUID: json['postUID'] as String,
      userUID: json['userUID'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postUID': postUID,
      'userUID': userUID,
      'date': date.toIso8601String(),
    };
  }
}