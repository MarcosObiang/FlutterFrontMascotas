/// Data Transfer Object (DTO) for login information.
class LoginDTO {
  /// The authentication token.
  String? token;

  /// The refresh token for renewing the authentication token.
  String? refreshToken;

  /// The unique identifier of the user.
  String? userUID;

  /// The expiriation date of the token
  DateTime? expirationDate;

  /// Creates a [LoginDTO] instance.
  ///
  /// [token] is the authentication token.
  /// [refreshToken] is the refresh token.
  factory LoginDTO.fromJson(Map<String, dynamic> json) {
    return LoginDTO(
      token: json['token'],
      refreshToken: (json['refreshToken']),
      userUID: json['userUID'],
      expirationDate: DateTime.parse(json['expirationDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refreshToken': refreshToken,
      'userUID': userUID,
      'expirationDate': expirationDate?.toIso8601String(),
    };
  }

  /// [userUID] is the user's unique identifier.
  /// [expirationDate] is the token's expiration date.
  LoginDTO({required this.token, required this.refreshToken, required this.userUID, required this.expirationDate});
}
