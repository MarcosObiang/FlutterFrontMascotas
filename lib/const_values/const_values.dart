class ConstValues {
  /// Cambiar a vuestra host de ngrok la variable [hostName] (la url sin el https://)

  static const String hostName =
      "c774-2a0c-5a81-3405-3900-7629-8b4c-df5a-2ec2.ngrok-free.app";

  static const String baseUrl = "https://${hostName}";

  static const String redirectUrl = "com.example.mascotascitas:/oauth2redirect";
  static const String googleClientId =
      "151798284057-dm71g2a9rbre2fdns23bo4s705ujk7r2.apps.googleusercontent.com";
  static const String discoveryUrl =
      "https://accounts.google.com/.well-known/openid-configuration";
  static const String issuer = "https://accounts.google.com";
}
