import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../cart/presentation/cubit/favorites_cubit.dart';
import '../../../dashboard/presentation/cubit/navigation_cubit.dart';
import '../../data/models/product_model.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("My Favorites", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: BlocBuilder<FavoritesCubit, List<ProductModel>>(
        builder: (context, state) {
          debugPrint("❤️ [FavoritesPage] Displaying ${state.length} favorites.");

          if (state.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined, size: 50, color: Colors.grey),
                  const SizedBox(height: 10),
                  const Text(
                      "Your cart is empty!",
                      style: TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.w500)
                  ),
                  const SizedBox(height: 24),

                  // 🛒 Start Shopping Button
                  ElevatedButton.icon(
                    onPressed: () {
                      debugPrint("🛒 [CartPage] Empty state: Navigating back to Home.");
                      context.read<NavigationCubit>().changeTab(0);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text("Go To Shopping", style: TextStyle(fontSize: 15)),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.length,
            itemBuilder: (context, index) {
              final product = state[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: product.thumbnail,
                      width: 60, height: 60, fit: BoxFit.cover,
                      placeholder: (context, url) => const CircularProgressIndicator(),
                    ),
                  ),
                  title: Text(product.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("₹${(product.price * 83).toStringAsFixed(0)}", style: const TextStyle(color: Colors.orange)),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () => context.read<FavoritesCubit>().toggleFavorite(product),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}