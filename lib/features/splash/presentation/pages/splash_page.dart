import 'package:flutter/material.dart';

import '../../../dashboard/presentation/pages/dashboard_page.dart';
// Note: We will import CatalogPage once we create it in the next step
// import '../../catalog/presentation/pages/catalog_page.dart';

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
      // For now, we stay on this page or show a message
      // because CatalogPage is not yet created.
      debugPrint("Splash finished, ready to navigate!");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
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
            // App Logo or Icon
            const Icon(
              Icons.shopping_bag_outlined,
              size: 80,
              color: Colors.deepPurple,
            ),
            const SizedBox(height: 20),
            // App Name
            Text(
              'ShopLite',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 10),
            // Subtitle or Loader
            const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
            ),
          ],
        ),
      ),
    );
  }
}