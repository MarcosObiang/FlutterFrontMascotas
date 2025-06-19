class ConstValues {
  /// Cambiar a vuestra host de ngrok la variable [hostName] (la url sin el https://)

  static const String hostName =
      "0b3d-2a0c-5a81-360d-f200-eae5-ee22-cc1b-5256.ngrok-free.app";



  static const String baseUrl = "https://$hostName";

  static const String redirectUrl = "com.example.mascotascitas:/oauth2redirect";
  static const String googleClientId =
      "151798284057-dm71g2a9rbre2fdns23bo4s705ujk7r2.apps.googleusercontent.com";
  static const String discoveryUrl =
      "https://accounts.google.com/.well-known/openid-configuration";
  static const String issuer = "https://accounts.google.com";
}
