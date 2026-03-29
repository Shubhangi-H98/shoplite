import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../cart/cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/profile_picture_cubit.dart';
import '../../../dashboard/presentation/cubit/navigation_cubit.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 🟢 Modified Profile Image for Dashboard
          BlocBuilder<ProfilePictureCubit, ProfilePictureState>(
            builder: (context, state) {
              return CircleAvatar(
                radius: 22,
                backgroundColor: Colors.orange,
                backgroundImage: state.imagePath != null
                    ? FileImage(File(state.imagePath!))
                    : null,
                child: state.imagePath == null
                    ? const Icon(Icons.person, color: Colors.white, size: 20)
                    : null,
              );
            },
          ),
          const SizedBox(width: 10),

          Expanded(
            child: BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                String displayName = "Guest";

                if (state is AuthAuthenticated) {
                  displayName = state.userName;
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello $displayName',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Text(
                      "Let's find something new!",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                );
              },
            ),
          ),

          // Action Icons (Notification & Cart)
          _buildActionIcon(Icons.notifications_none, () {}),
          const SizedBox(width: 4),
          _buildCartIcon(),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, VoidCallback onTap) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 24, color: Colors.black87),
    );
  }

  Widget _buildCartIcon() {
    return BlocBuilder<CartCubit, List>(
      builder: (context, cartItems) {
        int count = cartItems.length;
        return Stack(
          alignment: Alignment.topRight,
          children: [
            IconButton(
              onPressed: () {
                debugPrint("🛒 [HomeHeader] Navigating to Cart Tab via Cubit.");
                context.read<NavigationCubit>().changeTab(1);
              },
              icon: const Icon(Icons.shopping_bag_outlined, size: 24, color: Colors.black87),
            ),
            if (count > 0)
              Positioned(
                right: 6, top: 6,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                  child: Text('$count',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        );
      },
    );
  }
}