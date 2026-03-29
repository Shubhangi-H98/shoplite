import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shoplite/features/dashboard/presentation/pages/profile_page.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
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

  final List<Widget> _pages = [
    const CatalogPage(),    // Index 0: Home
    const CartPage(),       // Index 1: Shopping/Cart
    const FavoritesPage(),  // Index 2: Market/Favorites
    const ProfilePage(),    // Index 3: Account/Profile
  ];

  void _onItemTapped(int index) {
    final List<String> tabNames = ['Home', 'Cart', 'Favorites', 'Account'];
    debugPrint("📍 [Dashboard] Tab Switch: From ${tabNames[_selectedIndex]} to ${tabNames[index]}");

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          debugPrint("🔄 [Dashboard] User session ended. Redirecting to Login...");

          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.orange,
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
      ),
    );
  }
}