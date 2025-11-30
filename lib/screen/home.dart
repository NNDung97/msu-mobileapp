import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import '../main.dart'; // LocaleProvider
import '../providers/character_provider.dart';
import '../theme/app_colors.dart';

import 'login.dart';
import 'homescreen.dart';
import 'characters.dart';
import '../l10n/app_localizations.dart'; // Localization

class NavigatorHelper {
  static final GlobalKey<NavigatorState> homeNavigatorKey =
  GlobalKey<NavigatorState>();

  static final GlobalKey<CharacterPageState> characterPageKey =
  GlobalKey<CharacterPageState>();
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

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      _buildNavigator(NavigatorHelper.homeNavigatorKey, const HomeScreen()),
      _buildNavigator(
        GlobalKey<NavigatorState>(),
        CharactersPage(key: NavigatorHelper.characterPageKey),
      ),
    ];

    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final wallet = await _storage.read(key: 'wallet_address');
    setState(() => isLoggedIn = wallet != null && wallet.isNotEmpty);
  }

  void _onItemTapped(int index) {
    if (index == 1 && !isLoggedIn) {
      _showLoginRequiredDialog(index);
      return;
    }
    setState(() => _selectedIndex = index);
  }

  void _handleLoginButton() {
    if (isLoggedIn) {
      _showLogoutConfirmationDialog();
    } else {
      _navigateToLoginPage();
    }
  }

  // ---------------------------------------------------------------
  //                         DIALOGS
  // ---------------------------------------------------------------

  void _showLoginRequiredDialog(int targetIndex) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.loginRequired),
        content: Text(AppLocalizations.of(context)!.pleaseLogin),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.close),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToLoginPage(targetIndex: targetIndex);
            },
            child: Text(AppLocalizations.of(context)!.login),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.logoutConfirm),
        content: Text(AppLocalizations.of(context)!.logoutQuestion),
        actions: [
          TextButton(
            child: Text(AppLocalizations.of(context)!.cancel),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text(AppLocalizations.of(context)!.logout),
            onPressed: () {
              Navigator.pop(context);

              Provider.of<CharacterProvider>(context, listen: false)
                  .setCharacters([]);

              _storage.delete(key: 'wallet_address');

              setState(() {
                isLoggedIn = false;
                _selectedIndex = 0;
              });
            },
          ),
        ],
      ),
    );
  }

  void _navigateToLoginPage({int targetIndex = 1}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    ).then((result) async {
      if (result == true) {
        setState(() {
          isLoggedIn = true;
          _selectedIndex = targetIndex;
        });

        final state = NavigatorHelper.characterPageKey.currentState;
        if (state != null) await state.refreshData();
      }
    });
  }

  Widget _buildNavigator(GlobalKey<NavigatorState> key, Widget child) {
    return Navigator(
      key: key,
      onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => child),
    );
  }

  // ---------------------------------------------------------------
  //                         APP BAR
  // ---------------------------------------------------------------

  PreferredSizeWidget _buildAppBar() {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final lang = localeProvider.locale.languageCode;

    return AppBar(
      backgroundColor: AppColors.appBar,
      elevation: 0,

      // ⭐ Thêm line mờ dưới AppBar để chia ranh giới
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(
          height: 1,
          thickness: 1,
          color: Color(0x22FFFFFF), // trắng mờ 13%
        ),
      ),

      // Ngôn ngữ 🇻🇳 / 🇺🇸
      leading: IconButton(
        onPressed: () {
          if (lang == "en") {
            localeProvider.setLocale(const Locale("vi"));
          } else {
            localeProvider.setLocale(const Locale("en"));
          }
        },
        icon: Text(
          lang == "vi" ? "🇻🇳" : "🇺🇸",
          style: const TextStyle(fontSize: 22),
        ),
      ),

      // Ẩn title
      title: const SizedBox.shrink(),

      actions: [
        // Notification icon
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none, color: AppColors.text),
              onPressed: () {},
            ),
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '3',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),

        // LOGIN BUTTON (fixed width)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 110,   // 👈 chiều rộng tối thiểu
              maxWidth: 150,   // 👈 không cho nở quá to
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  colors: [
                    AppColors.buttonGradientStart,
                    AppColors.buttonGradientEnd,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  )
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _handleLoginButton,
                icon: Icon(
                  isLoggedIn ? Icons.logout : Icons.login,
                  size: 18,
                  color: Colors.white,
                ),
                label: FittedBox(
                  child: Text(
                    isLoggedIn
                        ? AppLocalizations.of(context)!.logout
                        : AppLocalizations.of(context)!.login,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  // ---------------------------------------------------------------
  //                     BOTTOM NAV BAR
  // ---------------------------------------------------------------

  Widget _buildBottomNavBar() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.navBar,
        border: Border(
          top: BorderSide(
            color: Color(0x33FFFFFF), // ⭐ line trắng mờ 20%
            width: 1,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: AppColors.navBar,
        unselectedItemColor: AppColors.unselected,
        selectedItemColor: AppColors.selected,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: AppLocalizations.of(context)!.home,
          ),
          BottomNavigationBarItem(
            icon: Icon(isLoggedIn ? Icons.person : Icons.lock_outline),
            label: isLoggedIn
                ? AppLocalizations.of(context)!.characters
                : AppLocalizations.of(context)!.login,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  //                        BUILD UI
  // ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }
}
