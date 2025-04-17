// models/match.dart
class Match {
  final String id;
  final String mascotaId1;
  final String mascotaId2;
  final DateTime fechaMatch;
  
  Match({
    required this.id,
    required this.mascotaId1,
    required this.mascotaId2,
    required this.fechaMatch,
  });
  
  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'],
      mascotaId1: json['mascotaId1'],
      mascotaId2: json['mascotaId2'],
      fechaMatch: DateTime.parse(json['fechaMatch']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mascotaId1': mascotaId1,
      'mascotaId2': mascotaId2,
      'fechaMatch': fechaMatch.toIso8601String(),
    };
  }
}