import 'package:flutter/foundation.dart';
import 'package:mascotas_citas/const_values/const_values.dart';

class Geturifromstring {
  factory Geturifromstring() {
    return _instance;
  }
  Geturifromstring._internal();
  static final Geturifromstring _instance = Geturifromstring._internal();

  /// Converts a given URL string into a complete URI with query parameters.

  String getUriFromString(String? urlString) {
    final baseUri = Uri.parse(
        "${ConstValues.baseUrl}/media-service/media/get-media"); // Ej: https://api.example.com

    return baseUri.replace(
      queryParameters: {
        if (urlString != null) 'fileName': urlString,
      },
    ).toString();
  }
}
