import 'package:flutter/material.dart';
import 'home.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const HomePage(title: 'Home'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 🔥 BACKGROUND IMAGE FULL SCREEN
          Image.asset(
            'lib/assets/images/msutrackersplash.png',
            fit: BoxFit.cover, // ⚠️ QUAN TRỌNG
          ),

          // 🔥 LAYER TỐI NHẸ (nếu muốn chữ/loader nổi hơn)
          Container(
            color: Colors.black.withOpacity(0.15),
          ),

          // 🔄 LOADING
          const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 48),
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
