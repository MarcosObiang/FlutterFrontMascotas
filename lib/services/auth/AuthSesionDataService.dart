/// `AuthdataService` is a class responsible for managing and persisting
/// authentication data, such as the authentication token, refresh token,
/// and user UID.
///
/// It utilizes a `SecureStorage` instance to securely store this data.
/// This class provides methods to set, retrieve, and clear these values,
/// ensuring data integrity and security.
library;

import 'package:flutter/foundation.dart';

import 'package:mascotas_citas/services/platform/storage/SecureStorage.dart';

class AuthDataService {
  SecureStorage secureStorage;

  AuthDataService({required this.secureStorage});

  /// The authentication token.
  String? token="";

  /// The refresh token.
  String? refreshToken="";

  /// The user's unique identifier (UID).
  String? userUID="";

  DateTime? expirationDate;

  /// Sets the authentication token.
  /// If the provided [token] is null or empty, it throws an [ArgumentError].
  /// It also handles potential errors during the storage process.
  ///
  /// Throws an [ArgumentError] if the token is null or empty.
  /// Throws an [Exception] if an error occurs during storage.
  Future<void> setToken(String? token) async {
  try {
    if (token == null || token.isEmpty) {
      // En lugar de lanzar un error, simplemente asignamos null o cadena vacía
      this.token = "";
      await secureStorage.delete("token");
    } else {
      this.token = token;
      await secureStorage.save("token", token);
    }
  } catch (e) {
    debugPrint("Error procesando token: $e");
    throw Exception("Error procesando token: $e");
  }
}

  /// Sets the refresh token.
  /// If the provided [refreshToken] is null or empty, it throws an [ArgumentError].
  /// It also handles potential errors during the storage process.
  ///
  /// Throws an [ArgumentError] if the refresh token is null or empty.
  /// Throws an [Exception] if an error occurs during storage.
  Future<void> setRefreshToken(String? refreshToken) async {
  try {
    if (refreshToken == null || refreshToken.isEmpty) {
      // En lugar de lanzar un error, simplemente asignamos cadena vacía
      this.refreshToken = "";
      await secureStorage.delete("refreshToken");
    } else {
      this.refreshToken = refreshToken;
      await secureStorage.save("refreshToken", refreshToken);
    }
  } catch (e) {
    debugPrint("Error procesando refresh token: $e");
    throw Exception("Error procesando refresh token: $e");
  }
}

  /// Sets the user's unique identifier (UID).
  /// If the provided [userUID] is null or empty, it throws an [ArgumentError].
  /// It also handles potential errors during the storage process.
  ///
  /// Throws an [ArgumentError] if the user UID is null or empty.
  /// Throws an [Exception] if an error occurs during storage.
  Future<void> setUserUID(String? userUID) async {
  try {
    if (userUID == null || userUID.isEmpty) {
      // En lugar de lanzar un error, asignamos cadena vacía
      this.userUID = "";
      await secureStorage.delete("userUID");
    } else {
      this.userUID = userUID;
      await secureStorage.save("userUID", userUID);
    }
  } catch (e) {
    debugPrint("Error procesando user UID: $e");
    throw Exception("Error procesando user UID: $e");
  }
}

  /// Clears all authentication data (token, refresh token, and user UID).
  /// It also handles potential errors during the clearing process.
  ///
  /// Throws an [Exception] if an error occurs during clearing.
  Future<void> clearAll() async {
    try {
      this.token = null;
      this.refreshToken = null;
      this.userUID = null;
      await secureStorage.delete("token");
      await secureStorage.delete("refreshToken");
      await secureStorage.delete("userUID");
    } catch (e) {
      debugPrint("Error clearing authentication data: $e");
      throw Exception("Error clearing authentication data: $e");
    }
  }

  Future<void> setExpirationDate(DateTime? expirationDate) async {
  try {
    if (expirationDate == null) {
      // En lugar de lanzar un error, limpiamos la fecha de expiración
      this.expirationDate = null;
      await secureStorage.delete("expirationDate");
    } else {
      this.expirationDate = expirationDate;
      await secureStorage.save("expirationDate", expirationDate.toString());
    }
  } catch (e) {
    debugPrint("Error procesando fecha de expiración: $e");
    throw Exception("Error procesando fecha de expiración: $e");
  }
}

  /// Retrieves the current authentication token.
  String? getToken() => token;

  /// Retrieves the current refresh token.
  String? getRefreshToken() => refreshToken;

  /// Retrieves the current user UID.
  String? getUserUID() => userUID;

  DateTime? getExpirationDate() => expirationDate;
}
