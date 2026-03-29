import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    debugPrint("🎬 [SplashPage] Screen Initialized.");
    // Auth status check trigger karna
    context.read<AuthCubit>().checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) async {
        debugPrint("🌊 [SplashPage] Observed AuthState: $state");

        // Branding delay
        await Future.delayed(const Duration(seconds: 3));

        if (!mounted) {
          debugPrint("⚠️ [SplashPage] Widget unmounted during delay. Aborting navigation.");
          return;
        }

        // Logic check for navigation
        if (state is AuthAuthenticated) {
          debugPrint("🏠 [SplashPage] Session Valid. Routing to Dashboard.");
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else if (state is AuthUnauthenticated || state is AuthInitial) {
          debugPrint("🔑 [SplashPage] No Session. Routing to Login.");
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shopping_bag_outlined, size: 100, color: Colors.orange),
              const SizedBox(height: 24),
              const Text(
                'ShopLite',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.orange),
              ),
              const SizedBox(height: 40),
              const CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
            ],
          ),
        ),
      ),
    );
  }
}