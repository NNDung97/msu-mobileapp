import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import '../providers/character_provider.dart';
import '../service/wallet_api_service.dart';
import '../model/characters.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _walletController = TextEditingController();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String _walletAddress = '';

  // Lưu địa chỉ ví vào secure storage
  Future<void> _saveWalletAddress(String address) async {
    await _storage.write(key: 'wallet_address', value: address);
  }

  // Đọc địa chỉ ví từ secure storage (Không dùng trong luồng này, nhưng giữ lại)
  Future<String?> _readWalletAddress() async {
    return await _storage.read(key: 'wallet_address');
  }

  // Xoá địa chỉ ví khỏi secure storage (Không dùng trong luồng này, nhưng giữ lại)
  Future<void> _deleteWalletAddress() async {
    await _storage.delete(key: 'wallet_address');
  }

  void _submitWallet() async {
    setState(() {
      _walletAddress = _walletController.text;
    });

    // 💡 Thêm chỉ báo đang tải (loading indicator)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Đang kết nối và tải dữ liệu...")),
    );

    // Gọi API
    final data = await WalletApiService.loginWallet(_walletAddress);

    if (data == null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Không thể đăng nhập ví! Vui lòng kiểm tra địa chỉ.")),
      );
      return;
    }

    // Parse characters
    final charactersJson = data["characters"]?["data"]?["characters"];
    List<Character> characters = [];

    if (charactersJson != null && charactersJson is List) {
      characters = charactersJson
          .map<Character>((c) => Character.fromJson(c))
          .toList();
    }

    // 1. Cập nhật Provider với danh sách nhân vật
    Provider.of<CharacterProvider>(context, listen: false)
        .setCharacters(characters);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("✅ Đăng nhập ví thành công. Tải ${characters.length} nhân vật.")),
    );

    // 2. Lưu local
    await _saveWalletAddress(_walletAddress);

    // 3. 🚨 SỬA LỖI ĐIỀU HƯỚNG: Sử dụng pop(true) để trả kết quả thành công về HomePage
    // Thay vì điều hướng (pushAndRemoveUntil), chúng ta thoát khỏi trang Login và trả về true.
    Navigator.pop(context, true); 

    // Debug log (không cần thiết trong production, có thể xóa)
    // String? savedWallet = await _readWalletAddress();
    // print("Saved wallet address: $savedWallet");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Khi nhấn nút back, trả về false để báo hiệu không thành công
            Navigator.pop(context, false); 
          },
        ),
      ),
      body: Stack(
        children: [
          // Background — scaled to focus the purple center. Adjust `scale` as needed.
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Transform.scale(
                  scale: 4, // increase to zoom in more; lower to zoom out
                  alignment: Alignment.center, // focus on the center (purple area)
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

          // Form nhập wallet
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // 💡 UI: Tối ưu TextField với Dark Theme
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
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none, // Bỏ border vì đã dùng Container
                        ),
                        hintText: 'Nhập địa chỉ ví',
                        contentPadding: const EdgeInsets.all(16),
                        prefixIcon: const Icon(Icons.account_balance_wallet, color: Colors.deepPurple),
                        hintStyle: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 💡 UI: Tối ưu nút Login
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      backgroundColor: Colors.deepPurpleAccent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.deepPurple.shade900,
                      elevation: 10,
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _submitWallet,
                    child: const Text('Login'),
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