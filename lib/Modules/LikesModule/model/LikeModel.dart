import 'package:equatable/equatable.dart';
import 'package:mascotas_citas/const_values/const_values.dart';

class LikeModel extends Equatable {
  String receiverUID; // Corrected typo: reciever -> receiver
  String senderUID;
  String petPictureURL; // Corrected typo: Pucture -> Picture
  String likeUID;
  String likedPetUID;
  bool isRevealed;
  String? petName;
  String? senderName;

  DateTime createdAt; // Changed to camelCase: created_at -> createdAt

  LikeModel({
    required this.receiverUID,
    required this.senderUID,
    required this.petPictureURL,
    required this.isRevealed,
    required this.likeUID,
    required this.likedPetUID,
    required this.createdAt,
    this.petName,
    this.senderName,
  });

  /// Converts this LikeModel instance into a Map (suitable for JSON/Firestore).
  Map<String, dynamic> toJson() {
    return {
      'receiverUID': receiverUID,
      'senderUID': senderUID,
      'petPictureURL': petPictureURL,
      'isRevealed': isRevealed,
      'likeUID': likeUID,
      'likedPetUID': likedPetUID,
      'petName': petName,
      'senderName': senderName,
      // Store DateTime as a Firestore Timestamp for better querying/sorting
      // or use .toIso8601String() if storing as a plain string.
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Creates a LikeModel instance from a Map (typically from JSON/Firestore).
  factory LikeModel.fromJson(Map<String, dynamic> json) {
    // Handle potential null or incorrect types gracefully
    final createdAtData = json['createdAt'];
    DateTime createdAt;

    if (createdAtData is DateTime) {
      // If it's already a Firestore Timestamp
      createdAt = createdAtData;
    } else if (createdAtData is String) {
      // If it's an ISO 8601 string
      createdAt = DateTime.parse(createdAtData);
    } else {
      // Fallback or error handling - using current time as a default here
      print(
          "Warning: 'createdAt' field is missing or not a Timestamp/String. Using current time.");
      createdAt = DateTime.now();
      // Alternatively, you could throw an error:
      // throw FormatException("Invalid format for 'createdAt': ${createdAtData.runtimeType}");
    }

    String getUriFromString(String? urlString) {
      final baseUri =
          Uri.parse("${ConstValues.baseUrl}/media-service/media/get-media"); // Ej: https://api.example.com

      return baseUri.replace(
        queryParameters: {
          if (urlString != null) 'fileName': urlString,
        },
      ).toString();
    }

    return LikeModel(
      receiverUID:
          json['receiverUID'] as String? ?? '', // Provide default if null
      senderUID: json['senderUID'] as String? ?? '',
      petPictureURL: getUriFromString(json['petPictureURL']) as String? ?? '',
      isRevealed: json['isRevealed'] as bool? ?? false,
      likeUID: json['likeUID'] as String? ?? '',
      likedPetUID: json['likedPetUID'] as String? ?? '',
      createdAt: createdAt,
      petName: json['petName'] as String? ?? '',
      senderName: json['senderName'] as String? ?? '',
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => [
        likeUID,
      ];
}
