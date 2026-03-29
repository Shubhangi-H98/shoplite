import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("My Account", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.orange,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 10),
          const Text("Test User", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Text("test@test.com", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 30),

          // Menu Options
          Expanded(
            child: ListView(
              children: [
                _buildMenuTile(Icons.shopping_bag_outlined, "My Orders", () {}),
                _buildMenuTile(Icons.favorite_border, "Wishlist", () {}),
                _buildMenuTile(Icons.location_on_outlined, "Shipping Address", () {}),
                _buildMenuTile(Icons.payment_outlined, "Payment Methods", () {}),
                const Divider(),
                // 🚪 Logout Button
                _buildMenuTile(
                  Icons.logout,
                  "Logout",
                      () => _showLogoutDialog(context),
                  textColor: Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, VoidCallback onTap, {Color? textColor}) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Colors.black),
      title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthCubit>().logout();
            },
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}