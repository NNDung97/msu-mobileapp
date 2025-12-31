import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// UI
import 'screen/home.dart';
import 'screen/splash_page.dart';

// PROVIDERS
import 'providers/character_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/auth_provider.dart';

// LOCALIZATION
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

// ONESIGNAL
import 'package:onesignal_flutter/onesignal_flutter.dart';

// LANGUAGE STATE
class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // =========================
  // ONESIGNAL INITIALIZATION
  // =========================
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

  OneSignal.initialize(
    "5c1db3c2-83eb-4f51-b881-e112129e93bf", // APP ID
  );

  // Request notification permission (Android 13+)
  await OneSignal.Notifications.requestPermission(true);

  // Observe permission state
  OneSignal.Notifications.addPermissionObserver((bool hasPermission) {
    debugPrint("🔔 Notification permission granted: $hasPermission");
  });

  // Handle foreground notification
  OneSignal.Notifications.addForegroundWillDisplayListener((event) {
    event.preventDefault(); // ❌ không show notification system
  });

  // Observe push subscription (FCM token)
  OneSignal.User.pushSubscription.addObserver((state) {
    debugPrint("📱 OneSignal Player ID: ${state.current.id}");
    debugPrint("📨 FCM Token: ${state.current.token}");
  });

  // Handle click notification
  OneSignal.Notifications.addClickListener((event) {
    debugPrint("👉 User opened notification: ${event.notification.title}");
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CharacterProvider()),
        ChangeNotifierProvider(create:  (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
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
    final localeProvider = context.watch<LocaleProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MSU App',

      locale: localeProvider.locale,

      supportedLocales: const [Locale('en'), Locale('vi')],

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      theme: ThemeData(
        useMaterial3: false,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),

      // home: const HomePage(title: 'Home'),
      home: const SplashPage(),
    );
  }
}
