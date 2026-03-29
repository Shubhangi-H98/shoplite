import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shoplite/features/dashboard/presentation/pages/profile_page.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../cart/presentation/cubit/favorites_cubit.dart';
import '../../../cart/presentation/pages/cart_page.dart';
import '../../../catalog/data/models/product_model.dart';
import '../../../catalog/presentation/pages/favorites_page.dart';
import '../cubit/navigation_cubit.dart';
import 'catalog_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // int _selectedIndex = 0;

  final List<Widget> _pages = [
    const CatalogPage(),    // Index 0: Home
    const CartPage(),       // Index 1: Shopping/Cart
    const FavoritesPage(),  // Index 2: Market/Favorites
    const ProfilePage(),    // Index 3: Account/Profile
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          debugPrint("🔄 [Dashboard] User session ended. Redirecting to Login...");
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        }
      },
      child: BlocBuilder<NavigationCubit, int>(
        builder: (context, activeIndex) {
          return Scaffold(
            body: IndexedStack(
              index: activeIndex,
              children: _pages,
            ),
            bottomNavigationBar: BlocBuilder<FavoritesCubit, List<ProductModel>>(
              builder: (context, favoritesList) {
                bool hasFavorites = favoritesList.isNotEmpty;

                return BottomNavigationBar(
                  currentIndex: activeIndex,
                  onTap: (index) {
                    context.read<NavigationCubit>().changeTab(index);
                  },
                  selectedItemColor: Colors.orange,
                  unselectedItemColor: Colors.grey,
                  showUnselectedLabels: true,
                  type: BottomNavigationBarType.fixed,
                  items: [
                    const BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
                    const BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Shopping'),
                    BottomNavigationBarItem(
                      icon: Icon(
                        hasFavorites ? Icons.favorite : Icons.favorite_border,
                        color: hasFavorites && activeIndex != 2 ? Colors.red : null,
                      ),
                      label: 'Market',
                    ),
                    const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}