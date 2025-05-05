class LikeModel {
  String receiverUID; // Corrected typo: reciever -> receiver
  String senderUID;
  String petPictureURL; // Corrected typo: Pucture -> Picture
  String likeUID;
  String likedPetUID;
  DateTime createdAt; // Changed to camelCase: created_at -> createdAt

  LikeModel({
    required this.receiverUID,
    required this.senderUID,
    required this.petPictureURL,
    required this.likeUID,
    required this.likedPetUID,
    required this.createdAt,
  });

  /// Converts this LikeModel instance into a Map (suitable for JSON/Firestore).
  Map<String, dynamic> toJson() {
    return {
      'receiverUID': receiverUID,
      'senderUID': senderUID,
      'petPictureURL': petPictureURL,
      'likeUID': likeUID,
      'likedPetUID': likedPetUID,
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

    return LikeModel(
      receiverUID:
          json['receiverUID'] as String? ?? '', // Provide default if null
      senderUID: json['senderUID'] as String? ?? '',
      petPictureURL: json['petPictureURL'] as String? ?? '',
      likeUID: json['likeUID'] as String? ?? '',
      likedPetUID: json['likedPetUID'] as String? ?? '',
      createdAt: createdAt,
    );
  }
}
