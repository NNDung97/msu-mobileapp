import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/character_provider.dart';
import 'screen/home.dart';

// LOCALIZATION
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

// FOR LANGUAGE STATE
class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }
}

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CharacterProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MSU App',

      // NGÔN NGỮ HIỆN TẠI
      locale: localeProvider.locale,

      // HỖ TRỢ NGÔN NGỮ
      supportedLocales: const [
        Locale('en'),
        Locale('vi'),
      ],

      // KHAI BÁO LOCALIZATION DELEGATES
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Giao diện chung
      theme: ThemeData(
        useMaterial3: false,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),

      home: const HomePage(title: 'Home'),
    );
  }
}
