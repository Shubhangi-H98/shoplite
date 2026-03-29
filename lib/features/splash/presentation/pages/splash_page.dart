import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  /// Handles navigation after a professional delay
  void _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {

      debugPrint("Splash finished, navigating to Login...");
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. App Logo/Icon - Updated to Orange
            const Icon(
              Icons.shopping_bag_outlined,
              size: 100,
              color: Colors.orange,
            ),
            const SizedBox(height: 24),

            // 2. App Name - Updated to Orange
            const Text(
              'ShopLite',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 40),

            // 3. Professional Loader - Updated to Orange
            const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
          ],
        ),
      ),
    );
  }
}