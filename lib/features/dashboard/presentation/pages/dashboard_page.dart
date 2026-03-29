import 'package:flutter/material.dart';

import '../../../cart/presentation/pages/cart_page.dart';
import '../../../catalog/presentation/pages/favorites_page.dart';
import 'catalog_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  // List of pages to display in the dashboard
  final List<Widget> _pages = [
    const CatalogPage(),
    const CartPage(),
    const FavoritesPage(),
    const Center(child: Text('Categories - Coming Soon')),
    const Center(child: Text('Cart - Empty')),
    const Center(child: Text('Profile - Login Required')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.orange, // Professional Orange theme
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Shopping'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Market'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }
}