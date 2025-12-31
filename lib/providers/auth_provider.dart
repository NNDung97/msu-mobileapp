import 'package:flutter/material.dart';

import '../service/auth_storage.dart';
import '../service/auth_service.dart';
import '../model/login_result.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  /// Gọi khi app start
  Future<void> syncAuthState() async {
    final wallet = await AuthStorage.getWalletAddress();
    _isLoggedIn = wallet != null && wallet.isNotEmpty;
    notifyListeners();
  }

  Future<void> login(LoginResult result) async {
  await AuthStorage.saveLogin(result);
  _isLoggedIn = true;
  notifyListeners();
}


  /// Logout từ UI / interceptor
  Future<void> logout() async {
    await AuthService.logoutInternal();
    _isLoggedIn = false;
    notifyListeners();
  }

  /// (OPTIONAL) Gọi sau login thành công
  void markLoggedIn() {
    _isLoggedIn = true;
    notifyListeners();
  }
}
