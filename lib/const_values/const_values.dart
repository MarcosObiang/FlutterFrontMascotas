class ConstValues {
  /// Cambiar a vuestra host de ngrok la variable [hostName] (la url sin el https://)

  static const String hostName =
      "15a6-85-61-96-56.ngrok-free.app";

  static const String baseUrl = "https://$hostName";

  static const String redirectUrl = "com.example.mascotascitas:/oauth2redirect";
  static const String googleClientId =
      "151798284057-dm71g2a9rbre2fdns23bo4s705ujk7r2.apps.googleusercontent.com";
  static const String discoveryUrl =
      "https://accounts.google.com/.well-known/openid-configuration";
  static const String issuer = "https://accounts.google.com";
}
