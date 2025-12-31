import 'package:flutter/material.dart';
import '../screen/home.dart';

class AppNavigator {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static void goHomeAndReset() {
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const HomePage(title: 'Home'),
      ),
      (route) => false,
    );
  }
}
