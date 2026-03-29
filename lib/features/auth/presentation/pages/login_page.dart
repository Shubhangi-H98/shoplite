import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _handleLogin() {
    debugPrint("🔘 [LoginPage] Login button pressed.");
    if (_formKey.currentState!.validate()) {
      debugPrint("📝 [LoginPage] Form validated. Calling AuthCubit.login()...");
      context.read<AuthCubit>().login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    } else {
      debugPrint("⚠️ [LoginPage] Form validation failed.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            debugPrint("⏳ [LoginPage] Auth state updated to: LOADING");
          } else if (state is AuthAuthenticated) {
            debugPrint("🚀 [LoginPage] Auth SUCCESS! Redirecting...");
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (state is AuthError) {
            debugPrint("❌ [LoginPage] Auth ERROR: ${state.message}");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  // Logo Container with debug info
                  GestureDetector(
                    onLongPress: () => debugPrint("💡 Tip: Use test@test.com / 123456"),
                    child: Center(
                      child: Container(
                        height: 80, width: 80,
                        decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), shape: BoxShape.circle),
                        child: const Icon(Icons.shopping_cart_rounded, size: 40, color: Colors.orange),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text("Welcome to ShopLite", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 40),

                  // Input Fields
                  _buildTextField(_emailController, "Email", Icons.email_outlined),
                  const SizedBox(height: 20),
                  _buildTextField(_passwordController, "Password", Icons.lock_outline, isPassword: true),

                  const SizedBox(height: 40),

                  // Login Button
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: state is AuthLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: state is AuthLoading
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text("Login", style: TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
      validator: (value) => value == null || value.isEmpty ? '$label is required' : null,
    );
  }
}