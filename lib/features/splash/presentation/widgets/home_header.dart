import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint("🏠 [HomeHeader] Building header widget.");

    return Row(
      children: [
        const CircleAvatar(
          radius: 25,
          backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=alex'),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hello Alex', style: TextStyle(color: Colors.grey, fontSize: 14)),
            Text('Good Morning!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        const Spacer(),
        IconButton.filledTonal(
          onPressed: () {
            debugPrint("🔔 [HomeHeader] Notifications icon pressed.");
          },
          icon: const Icon(Icons.notifications_none),
        ),
        IconButton.filledTonal(
          onPressed: () {
            debugPrint("🛒 [HomeHeader] Cart/Shopping bag icon pressed from header.");
          },
          icon: const Icon(Icons.shopping_bag_outlined),
        ),
      ],
    );
  }
}