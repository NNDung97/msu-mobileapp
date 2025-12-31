import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import '../providers/character_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/auth_provider.dart';
import '../service/wallet_api_service.dart';
import '../service/auth_storage.dart';
import '../model/login_result.dart';
import '../model/characters.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _walletController = TextEditingController();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _isLoading = false;

  Future<void> _saveAuth({
    required String wallet,
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: 'wallet_address', value: wallet);
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }

  bool _isValidWallet(String wallet) {
    return wallet.startsWith('0x') && wallet.length >= 40;
  }

  Future<void> _submitWallet() async {
    final wallet = _walletController.text.trim();

    if (!_isValidWallet(wallet)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Địa chỉ ví không hợp lệ")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ✅ MODEL, KHÔNG PHẢI MAP
      final LoginResult? result = await WalletApiService.loginWallet(wallet);

      if (result == null) {
        throw Exception("Login failed");
      }
      // 🔐 Lưu auth
        // await AuthStorage.saveLogin(result);
        await context.read<AuthProvider>().login(result);


        if (!context.mounted) return;

      // 🔐 Lưu auth
      // await _saveAuth(
      //   wallet: wallet,
      //   accessToken: result.accessToken,
      //   refreshToken: result.refreshToken,
      // );

      // 👤 Set characters vào Provider
      Provider.of<CharacterProvider>(
        context,
        listen: false,
      ).setCharacters(result.characters);

      // 🔔 INIT SOCKET + NOTIFICATION
      // Provider.of<NotificationProvider>(
      //   context,
      //   listen: false,
      // ).initSocket(result.userId, result.accessToken);
      // 🔔 LẤY NotificationProvider
      final notifyProvider = Provider.of<NotificationProvider>(
        context,
        listen: false,
      );

      // 🔔 INIT SOCKET
      notifyProvider.initSocket(result.userId, result.accessToken);

      // 🔥 SYNC UNREAD COUNT (DÒNG BẠN THIẾU)
      await notifyProvider.syncUnreadCount();

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Đăng nhập thất bại, vui lòng thử lại")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: Stack(
        children: [
          // ===== BACKGROUND — GIỮ NGUYÊN =====
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Transform.scale(
                  scale: 4,
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    child: Image.asset(
                      'lib/assets/images/background.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned.fill(
            child: Transform.scale(
              scale: 1.0,
              child: Image.asset(
                "lib/assets/images/yeti.png",
                fit: BoxFit.contain,
                alignment: Alignment.bottomLeft,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 250,
            top: 100,
            bottom: 0,
            child: Transform.scale(
              scale: 1,
              child: Image.asset(
                "lib/assets/images/orange.png",
                fit: BoxFit.contain,
                alignment: Alignment.center,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 150,
            top: 0,
            bottom: 500,
            child: Transform.scale(
              scale: 0.55,
              child: Image.asset(
                "lib/assets/images/pinkbean.png",
                fit: BoxFit.fill,
                alignment: Alignment.topRight,
              ),
            ),
          ),
          Positioned(
            left: 150,
            right: 0,
            top: 0,
            bottom: 300,
            child: Transform.scale(
              scale: 0.75,
              child: Image.asset(
                "lib/assets/images/bishop.png",
                fit: BoxFit.fill,
                alignment: Alignment.topRight,
              ),
            ),
          ),

          // ===== FORM LOGIN (logic đã sửa) =====
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _walletController,
                      enabled: !_isLoading,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        hintText: 'Nhập địa chỉ ví',
                        contentPadding: const EdgeInsets.all(16),
                        prefixIcon: const Icon(
                          Icons.account_balance_wallet,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitWallet,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      backgroundColor: Colors.deepPurpleAccent,
                      foregroundColor: Colors.white,
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../providers/character_provider.dart';
// import '../providers/notification_provider.dart';
// import '../service/wallet_api_service.dart';
// import '../service/auth_storage.dart';
// import '../model/login_result.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final TextEditingController _walletController = TextEditingController();
//   bool _isLoading = false;

//   bool _isValidWallet(String wallet) {
//     return wallet.startsWith('0x') && wallet.length >= 40;
//   }

//   Future<void> _submitWallet() async {
//     final wallet = _walletController.text.trim();

//     if (!_isValidWallet(wallet)) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("❌ Địa chỉ ví không hợp lệ")),
//       );
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       // ===== LOGIN API =====
//       final LoginResult? result =
//           await WalletApiService.loginWallet(wallet);

//       if (result == null) {
//         throw Exception("Login failed");
//       }

//       // ===== SAVE AUTH (CHỈ 1 CHỖ) =====
//       await AuthStorage.saveLogin(result);

//       if (!context.mounted) return;

//       // ===== RESET STATE CŨ =====
//       Provider.of<CharacterProvider>(context, listen: false).clear();
//       Provider.of<NotificationProvider>(context, listen: false)
//           .disconnectSocket();

//       // ===== SET CHARACTER =====
//       Provider.of<CharacterProvider>(
//         context,
//         listen: false,
//       ).setCharacters(result.characters);

//       // ===== INIT NOTIFICATION =====
//       final notifyProvider =
//           Provider.of<NotificationProvider>(context, listen: false);

//       notifyProvider.initSocket(
//         result.userId,
//         result.accessToken,
//       );

//       await notifyProvider.syncUnreadCount();

//       if (!context.mounted) return;
//       Navigator.pop(context, true);
//     } catch (e) {
//       if (!context.mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("❌ Đăng nhập thất bại, vui lòng thử lại"),
//         ),
//       );
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context, false),
//         ),
//       ),
//       body: Stack(
//         children: [
//           Positioned.fill(
//             child: Image.asset(
//               'lib/assets/images/background.png',
//               fit: BoxFit.cover,
//             ),
//           ),
//           Center(
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.9),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: TextField(
//                       controller: _walletController,
//                       enabled: !_isLoading,
//                       decoration: const InputDecoration(
//                         hintText: 'Nhập địa chỉ ví',
//                         prefixIcon:
//                             Icon(Icons.account_balance_wallet),
//                         border: InputBorder.none,
//                         contentPadding: EdgeInsets.all(16),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: _isLoading ? null : _submitWallet,
//                     child: _isLoading
//                         ? const CircularProgressIndicator(
//                             strokeWidth: 2,
//                             color: Colors.white,
//                           )
//                         : const Text("Login"),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
