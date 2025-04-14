import 'package:flutter_secure_storage_x/flutter_secure_storage_x.dart';

class SecureStorage {
  FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<void> save(String key, String value) async {
    await storage.write(key: key, value: value, aOptions: _getAndroidOptions());
  }

  Future<String?> read(String key) async {
    return await storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await storage.delete(key: key);
  }

  AndroidOptions _getAndroidOptions() => const AndroidOptions(
        dataStore: true,
      );
}
