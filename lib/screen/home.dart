// File: lib/screens/home.dart

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import '../providers/character_provider.dart';
import 'login.dart';
import 'homescreen.dart';
import 'characters.dart';

// 🚨 BƯỚC 1: Cần import CharacterPageState từ characters.dart
// Nếu bạn đã sửa characters.dart theo hướng dẫn trước, CharacterPageState là public.
// Bạn có thể phải thêm: import 'characters.dart';
// (Đã có sẵn trong file của bạn, nên ta chỉ cần định nghĩa lại NavigatorHelper)

// --- Global Keys (Cần phải có) ---
class NavigatorHelper {
  static final GlobalKey<NavigatorState> homeNavigatorKey = GlobalKey<NavigatorState>();
  
  // 🚨 SỬA: Key để truy cập State của CharactersPage
  // (Giả định bạn đã đổi tên State sang CharacterPageState trong characters.dart)
  static final GlobalKey<CharacterPageState> characterPageKey = GlobalKey<CharacterPageState>();
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  int _selectedIndex = 0; 
  bool isLoggedIn = false;

  final List<String> _titles = ["Home", "Characters"];

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // 🚨 BƯỚC 2: Gán GlobalKey cho CharactersPage
    _pages = [
      _buildNavigator(NavigatorHelper.homeNavigatorKey, const HomeScreen()),
      _buildNavigator(
        GlobalKey<NavigatorState>(), // Dùng Key thường cho Navigator nếu bạn không cần điều hướng sâu bên trong tab này
        CharactersPage(key: NavigatorHelper.characterPageKey), // 🚨 GÁN CharacterPageKey
      ),
    ];
    _checkLoginStatus();
  }

  // MARK: - LOGIC QUẢN LÝ TRẠNG THÁI
  
  Future<void> _checkLoginStatus() async {
    final wallet = await _storage.read(key: 'wallet_address');
    setState(() {
      isLoggedIn = wallet != null && wallet.isNotEmpty;
    });
  }

  // ✅ Hàm này không còn cần thiết vì LoginPage sẽ tự lưu ví.
  // Future<void> _saveWalletAddress(String address) async {
  //   await _storage.write(key: 'wallet_address', value: address);
  // }
  
  void _onItemTapped(int index) async {
    if (index == 1 && !isLoggedIn) {
      _showLoginRequiredDialog(index);
      return; 
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  void _handleLoginButton() {
    if (isLoggedIn) {
      _showLogoutConfirmationDialog();
    } else {
      _navigateToLoginPage();
    }
  }

  // MARK: - DIALOGS VÀ NAVIGATION
  
  void _showLoginRequiredDialog(int targetIndex) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Chưa đăng nhập"),
        content: const Text("Vui lòng đăng nhập hoặc kết nối ví để xem nhân vật."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Đóng"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToLoginPage(targetIndex: targetIndex);
            },
            child: const Text("Đăng nhập"),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận đăng xuất"),
        content: const Text("Bạn có chắc chắn muốn đăng xuất?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              
              Provider.of<CharacterProvider>(context, listen: false).setCharacters([]);
              _storage.delete(key: 'wallet_address');
              
              setState(() {
                isLoggedIn = false;
                _selectedIndex = 0; 
              });
            },
            child: const Text("Đăng xuất"),
          ),
        ],
      ),
    );
  }

  // 🔹 Điều hướng đến trang Login (Đã thêm logic Refresh CharactersPage)
  void _navigateToLoginPage({int targetIndex = 1}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    ).then((result) async { // 🚨 Thêm async/await ở đây
      if (result == true) { // Nhận true khi login thành công
        // 1. Cập nhật trạng thái Home Page
        setState(() {
          isLoggedIn = true;
          _selectedIndex = targetIndex; 
        });
        
        // 2. 🚨 GỌI TẢI LẠI DỮ LIỆU TỪ CharactersPage State
        final characterState = NavigatorHelper.characterPageKey.currentState;
        if (characterState != null) {
          // Hàm refreshData() sẽ đọc lại ví từ storage và tải nhân vật
          await characterState.refreshData(); 
        }
      }
    });
  }

  Widget _buildNavigator(GlobalKey<NavigatorState> key, Widget child) {
    return Navigator(
      key: key,
      onGenerateRoute: (settings) =>
          MaterialPageRoute(builder: (context) => child),
    );
  }

  // MARK: - WIDGETS UI
  
  PreferredSizeWidget _buildAppBar() {
    // ... (Giữ nguyên logic AppBar)
    const Color appBarColor = Color(0xFF1B0F33);
    const Color primaryIconColor = Color(0xFFF9A825);
    const Color textColor = Colors.white;

    return AppBar(
      backgroundColor: appBarColor,
      elevation: 4,
      centerTitle: true,
      title: Text(
        _titles[_selectedIndex],
        style: const TextStyle(fontWeight: FontWeight.bold, color: textColor),
      ),
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none, color: textColor),
              onPressed: () { /* handle notifications */ },
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: appBarColor, width: 1.5),
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: const Text(
                  '3',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, height: 1.0),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          child: ElevatedButton.icon(
            onPressed: _handleLoginButton,
            style: ElevatedButton.styleFrom(
              backgroundColor: isLoggedIn ? Colors.red.shade600 : primaryIconColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            ),
            icon: Icon(isLoggedIn ? Icons.logout : Icons.login, size: 18),
            label: Text(
              isLoggedIn ? "Logout" : "Login",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    // ... (Giữ nguyên logic Bottom NavBar)
    const Color navBarColor = Color(0xFF1B0F33);
    const Color unselectedColor = Colors.white54;
    const Color selectedColor = Color(0xFFF9A825);

    return Container(
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(color: Colors.black45, blurRadius: 10, spreadRadius: 0),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: navBarColor,
        unselectedItemColor: unselectedColor,
        selectedItemColor: selectedColor,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              isLoggedIn ? Icons.person : Icons.lock_outline,
            ),
            label: isLoggedIn ? "Character" : "Log in",
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0821),
      appBar: _buildAppBar(),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }
}