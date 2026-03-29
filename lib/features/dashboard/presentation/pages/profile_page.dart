import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../cart/presentation/cubit/favorites_cubit.dart';
import '../../../cart/presentation/cubit/order_cubit.dart';
import '../cubit/navigation_cubit.dart';
import 'edit_address_page.dart';
import 'payment_methods_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _storage = const FlutterSecureStorage();
  String? _savedAddress;

  @override
  void initState() {
    super.initState();
    _loadAddress();
  }

  Future<void> _loadAddress() async {
    final address = await _storage.read(key: 'last_shipping_address');
    if (mounted) setState(() => _savedAddress = address);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("My Account", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          String name = "Guest User";
          String email = "Not Logged In";

          if (authState is AuthAuthenticated) {
            name = authState.userName;
            email = authState.userEmail;
          }

          return Column(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.orange,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : "U",
                  style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text(email, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 30),

              Expanded(
                child: ListView(
                  children: [
                    _buildMenuTile(Icons.shopping_bag_outlined, "My Orders", () {
                      context.read<NavigationCubit>().changeTab(1);
                    }),

                    // 1. Dynamic Wishlist Count
                    BlocBuilder<FavoritesCubit, List>(
                      builder: (context, favs) => _buildMenuTile(
                        Icons.favorite_border,
                        "Wishlist",
                            () => context.read<NavigationCubit>().changeTab(2),
                        trailingText: favs.isNotEmpty ? "${favs.length} Items" : "0 Items",
                      ),
                    ),

                    // 2. 🟢 Dynamic Shipping Address (Navigation Added)
                    _buildMenuTile(
                      Icons.location_on_outlined,
                      "Shipping Address",
                          () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const EditAddressPage()),
                        );
                        if (result == true) _loadAddress();
                      },
                      trailingText: _savedAddress != null
                          ? (_savedAddress!.length > 15 ? "${_savedAddress!.substring(0, 15)}..." : _savedAddress)
                          : "No address saved",
                    ),

                    // 3. 🟢 Dynamic Payment Method (Navigation Added)
                    BlocBuilder<OrderCubit, List<OrderModel>>(
                      builder: (context, orders) {
                        String lastPayment = orders.isNotEmpty ? orders.first.paymentMethod : "None";
                        return _buildMenuTile(
                          Icons.payment_outlined,
                          "Payment Methods",
                              () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const PaymentMethodsPage()),
                            );
                          },
                          trailingText: lastPayment,
                        );
                      },
                    ),

                    const Divider(),
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
          );
        },
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, VoidCallback onTap, {Color? textColor, String? trailingText}) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Colors.black),
      title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(trailingText, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
        ],
      ),
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
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Cancel")),
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