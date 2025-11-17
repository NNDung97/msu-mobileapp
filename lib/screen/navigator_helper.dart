import 'package:flutter/material.dart';

class NavigatorHelper {
  static final GlobalKey<NavigatorState> searchNavigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> homeNavigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> characterNavigatorKey = GlobalKey<NavigatorState>();

  static Future<void> push(BuildContext context, Widget page) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  static Future<void> pushNamed(BuildContext context, String routeName) async {
    await Navigator.of(context).pushNamed(routeName);
  }

  static void pop(BuildContext context) {
    Navigator.of(context).pop();
  }
}
