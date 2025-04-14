abstract class IAuthServices {
  Future<Map<String, dynamic>?> login();
  Future<void> logout();
  Future<void> refreshToken({required String refreshToken});
}
