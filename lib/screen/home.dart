import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart'; // LocaleProvider
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../theme/app_colors.dart';

import 'login.dart';
import 'homescreen.dart';
import 'characters.dart';
import 'notifications.dart';
import '../l10n/app_localizations.dart';

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
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    context.read<NotificationProvider>().syncUnreadCount();

    _pages = [
      _buildNavigator(
        NavigatorHelper.homeNavigatorKey,
        const HomeScreen(),
      ),
      _buildNavigator(
        GlobalKey<NavigatorState>(),
        CharactersPage(key: NavigatorHelper.characterPageKey),
      ),
    ];
  }

  // ---------------------------------------------------------------
  //                      NAVIGATION LOGIC
  // ---------------------------------------------------------------

  void _onItemTapped(int index) {
    final isLoggedIn = context.read<AuthProvider>().isLoggedIn;
    print(  '🏠 Bottom nav tapped: index=$index, isLoggedIn=$isLoggedIn');

    // if (index == 1 && !isLoggedIn) {
    //   _showLoginRequiredDialog(index);
    //   return;
    // }

    setState(() => _selectedIndex = index);
  }

  void _handleLoginButton() {
    final isLoggedIn = context.read<AuthProvider>().isLoggedIn;

    if (isLoggedIn) {
      _showLogoutConfirmationDialog();
    } else {
      _navigateToLoginPage();
    }
  }

  // ---------------------------------------------------------------
  //                          DIALOGS
  // ---------------------------------------------------------------

  void _showLoginRequiredDialog(int targetIndex) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A), // Dark Kurumi background
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          AppLocalizations.of(context)!.loginRequired,
          style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
        ),
        content: Text(
          AppLocalizations.of(context)!.pleaseLogin,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.close, style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[900],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: () {
              Navigator.pop(context);
              _navigateToLoginPage(targetIndex: targetIndex);
            },
            child: Text(AppLocalizations.of(context)!.login, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          AppLocalizations.of(context)!.logoutConfirm,
          style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
        ),
        content: Text(
          AppLocalizations.of(context)!.logoutQuestion,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel, style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[900],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().logout();
              setState(() => _selectedIndex = 0);
            },
            child: Text(AppLocalizations.of(context)!.logout, style: const TextStyle(color: Colors.white)),
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
        setState(() => _selectedIndex = targetIndex);

        final state = NavigatorHelper.characterPageKey.currentState;
        if (state != null) {
          await state.refreshData();
        }
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
  //                        APP BAR
  // ---------------------------------------------------------------

  PreferredSizeWidget _buildAppBar() {
    final localeProvider = context.watch<LocaleProvider>();
    final lang = localeProvider.locale.languageCode;
    final isLoggedIn = context.watch<AuthProvider>().isLoggedIn;
    
    // Lấy số lượng thông báo chưa đọc từ Provider
    final unreadCount = context.watch<NotificationProvider>().unreadCount;

    return AppBar(
      backgroundColor: const Color(0xFF0D0D0D), // Ultra dark for Kurumi theme
      elevation: 0,
      centerTitle: false,
      titleSpacing: 10,
      leadingWidth: 50,
      leading: Center(
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            localeProvider.setLocale(
              lang == "en" ? const Locale("vi") : const Locale("en"),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.redAccent.withOpacity(0.5), width: 1),
            ),
            child: Text(lang == "vi" ? "🇻🇳" : "🇺🇸", style: const TextStyle(fontSize: 16)),
          ),
        ),
      ),
      actions: [
        // Notification Icon with dynamic badge
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.white, size: 28),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationPage()),
                );
                context.read<NotificationProvider>().syncUnreadCount();
              },
            ),
            // Chỉ hiện badge khi có thông báo (unreadCount > 0)
            if (unreadCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red[700], 
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF0D0D0D), width: 1.5),
                  ),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  child: Center(
                    child: Text(
                      unreadCount > 99 ? '99+' : unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              )
          ],
        ),
        
        // --- UPGRADED LOGIN/LOGOUT BUTTON ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: GestureDetector(
            onTap: _handleLoginButton,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isLoggedIn 
                    ? [const Color(0xFF4A0000), const Color(0xFF8B0000)] // Dark Red for logout
                    : [const Color(0xFFFFD700), const Color(0xFFB8860B)], // Gold for login (High Contrast)
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: (isLoggedIn ? Colors.red : Colors.orange).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isLoggedIn ? Icons.power_settings_new : Icons.vpn_key_rounded,
                      color: isLoggedIn ? Colors.white : Colors.black87,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isLoggedIn
                          ? AppLocalizations.of(context)!.logout.toUpperCase()
                          : AppLocalizations.of(context)!.login.toUpperCase(),
                      style: TextStyle(
                        color: isLoggedIn ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------
  //                    BOTTOM NAV BAR
  // ---------------------------------------------------------------

  Widget _buildBottomNavBar() {
    final isLoggedIn = context.watch<AuthProvider>().isLoggedIn;

    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF333333), width: 0.5)),
      ),
      child: BottomNavigationBar(
        backgroundColor: const Color(0xFF0D0D0D),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFFFFD700), // Gold for active
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: AppLocalizations.of(context)!.home,
          ),
          BottomNavigationBarItem(
            icon: Icon(isLoggedIn ? Icons.person_outline : Icons.lock_outline),
            activeIcon: Icon(isLoggedIn ? Icons.person : Icons.lock_open),
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
      backgroundColor: const Color(0xFF121212), // Dark Kurumi theme background
      appBar: _buildAppBar(),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }
}