class ConstValues {
  /// Cambiar a vuestra host de ngrok la variable [hostName] (la url sin el https://)

  static const String hostName =
      //"10ab-2a0c-5a81-3405-3900-87c5-481f-23c0-f6ec.ngrok-free.app";
      "5bce-2a0c-5a85-ee06-4c00-3808-a574-7bac-fea3.ngrok-free.app";


  static const String baseUrl = "https://${hostName}";

  static const String redirectUrl = "com.example.mascotascitas:/oauth2redirect";
  static const String googleClientId =
      "151798284057-dm71g2a9rbre2fdns23bo4s705ujk7r2.apps.googleusercontent.com";
  static const String discoveryUrl =
      "https://accounts.google.com/.well-known/openid-configuration";
  static const String issuer = "https://accounts.google.com";
}
