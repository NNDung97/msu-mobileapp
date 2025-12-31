import 'package:provider/provider.dart';

import '../service/auth_storage.dart';
import '../providers/character_provider.dart';
import '../providers/notification_provider.dart';
import '../navigation/app_navigator.dart';

class AuthService {
  /// ❗ CHỈ AuthProvider gọi
  static Future<void> logoutInternal() async {
    // 1. Clear token / wallet / refresh token
    await AuthStorage.clear();

    // 2. Reset các provider liên quan
    final context = AppNavigator.navigatorKey.currentContext;
    if (context != null) {
      context.read<CharacterProvider>().setCharacters([]);
      context.read<NotificationProvider>().clear();
    }

    // 3. Điều hướng về Home (clear stack)
    AppNavigator.goHomeAndReset();
  }
}
