import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../model/login_result.dart';

class AuthStorage {
  static const _storage = FlutterSecureStorage();

  // ===== LOGIN =====
  static Future<void> saveLogin(LoginResult result) async {
    await _storage.write(key: "access_token", value: result.accessToken);
    await _storage.write(key: "refresh_token", value: result.refreshToken);
    await _storage.write(key: "wallet_address", value: result.walletAddress);
    await _storage.write(key: "user_id", value: result.userId);
  }

  // ===== TOKEN =====
  static Future<String?> getAccessToken() => _storage.read(key: "access_token");

  static Future<String?> getRefreshToken() => _storage.read(key: "refresh_token");

  static Future<String?> getWalletAddress() => _storage.read(key: "wallet_address");

  static Future<void> updateAccessToken(String token) async {
    await _storage.write(key: "access_token", value: token);
  }

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: "access_token", value: accessToken);
    await _storage.write(key: "refresh_token", value: refreshToken);
  }

  // ===== USER =====
  static Future<String?> getUserId() => _storage.read(key: "user_id");

  // ===== LOGOUT =====
  static Future<void> clear() async {
    await _storage.deleteAll();
  }
}
