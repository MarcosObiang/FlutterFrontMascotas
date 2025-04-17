// models/mensaje.dart
class Mensaje {
  final String id;
  final String matchId;
  final String emisorId;
  final String contenido;
  final DateTime fechaEnvio;
  final bool leido;
  
  Mensaje({
    required this.id,
    required this.matchId,
    required this.emisorId,
    required this.contenido,
    required this.fechaEnvio,
    required this.leido,
  });
  
  factory Mensaje.fromJson(Map<String, dynamic> json) {
    return Mensaje(
      id: json['id'],
      matchId: json['matchId'],
      emisorId: json['emisorId'],
      contenido: json['contenido'],
      fechaEnvio: DateTime.parse(json['fechaEnvio']),
      leido: json['leido'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'matchId': matchId,
      'emisorId': emisorId,
      'contenido': contenido,
      'fechaEnvio': fechaEnvio.toIso8601String(),
      'leido': leido,
    };
  }
}