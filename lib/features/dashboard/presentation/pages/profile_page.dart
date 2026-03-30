import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/theme_cubit.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/pages/orders_page.dart';
import '../../../cart/presentation/cubit/favorites_cubit.dart';
import '../../../cart/presentation/cubit/order_cubit.dart';
import '../../../cart/presentation/cubit/profile_picture_cubit.dart';
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

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (!context.mounted) return;
    if (image != null) {
      context.read<ProfilePictureCubit>().updateProfilePicture(image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Account", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          String name = "Guest User";
          String email = "Not Logged In";
          if (authState is AuthAuthenticated) {
            name = authState.userName;
            email = authState.userEmail;
          }

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 20),
            children: [
              Center(
                child: GestureDetector(
                  onTap: () => _pickImage(context),
                  child: BlocBuilder<ProfilePictureCubit, ProfilePictureState>(
                    builder: (context, state) {
                      return CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.orange,
                        backgroundImage: state.imagePath != null ? FileImage(File(state.imagePath!)) : null,
                        child: state.imagePath == null
                            ? Text(name.isNotEmpty ? name[0].toUpperCase() : "U",
                            style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold))
                            : null,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text(email, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 30),

              BlocBuilder<OrderCubit, List<OrderModel>>(
                builder: (context, orders) {
                  return _buildMenuTile(
                    Icons.shopping_bag_outlined,
                    "My Orders",
                        () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const OrdersPage())
                      );
                    },
                    trailingText: orders.isNotEmpty ? "${orders.length} Orders" : null,
                  );
                },
              ),
              BlocBuilder<FavoritesCubit, List>(
                builder: (context, favs) => _buildMenuTile(
                  Icons.favorite_border, "Wishlist",
                      () => context.read<NavigationCubit>().changeTab(2),
                  trailingText: "${favs.length} Items",
                ),
              ),
              _buildMenuTile(Icons.location_on_outlined, "Shipping Address", () async {
                final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const EditAddressPage()));
                if (result == true) _loadAddress();
              }, trailingText: _savedAddress ?? "No address saved"),
              BlocBuilder<OrderCubit, List<OrderModel>>(
                builder: (context, orders) {
                  String lastPayment = orders.isNotEmpty ? orders.first.paymentMethod : "None";
                  return _buildMenuTile(Icons.payment_outlined, "Payment Methods", () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentMethodsPage()));
                  }, trailingText: lastPayment);
                },
              ),

              BlocBuilder<ThemeCubit, bool>(
                builder: (context, isDark) {
                  return SwitchListTile(
                    title: const Text("Dark Mode", style: TextStyle(fontWeight: FontWeight.w500)),
                    secondary: Icon(
                      isDark ? Icons.dark_mode : Icons.light_mode,

                      color: isDark ? Colors.orange : null,
                    ),
                    activeColor: Colors.orange,
                    value: isDark,
                    onChanged: (value) {
                      context.read<ThemeCubit>().toggleTheme();
                    },
                  );
                },
              ),

              const Divider(),
              _buildMenuTile(Icons.logout, "Logout", () => _showLogoutDialog(context), textColor: Colors.red),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, VoidCallback onTap, {Color? textColor, String? trailingText}) {
    return ListTile(
      leading: Icon(icon, color: textColor),
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