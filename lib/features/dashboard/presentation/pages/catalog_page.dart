import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../cart/cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/favorites_cubit.dart';
import '../../../catalog/data/models/product_model.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../../catalog/presentation/cubit/catalog_cubit.dart';
import '../../../catalog/presentation/cubit/catalog_state.dart';
import '../../../product_detail/presentation/pages/product_detail_page.dart';
import '../../../splash/presentation/widgets/home_header.dart';
import '../../../dashboard/presentation/cubit/navigation_cubit.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  bool _showBackToTop = false;
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    context.read<CatalogCubit>().fetchProducts();
    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      if (currentScroll >= maxScroll * 0.8) {
        context.read<CatalogCubit>().loadMore();
      }
      if (currentScroll >= 400) {
        if (!_showBackToTop) setState(() => _showBackToTop = true);
      } else {
        if (_showBackToTop) setState(() => _showBackToTop = false);
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: _showBackToTop
          ? FloatingActionButton(
        onPressed: () => _scrollController.animateTo(0,
            duration: const Duration(milliseconds: 600), curve: Curves.easeInOut),
        backgroundColor: Colors.orange,
        mini: true,
        child: const Icon(Icons.arrow_upward, color: Colors.white),
      )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: HomeHeader(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _buildSearchBar(),
            ),
            _buildCategoryList(),
            const SizedBox(height: 8),
            const Divider(height: 1, color: Color(0xFFF5F5F5)),
            Expanded(
              child: BlocBuilder<CatalogCubit, CatalogState>(
                builder: (context, state) {
                  return CustomScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverToBoxAdapter(child: _buildPromoBanner()),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        sliver: SliverToBoxAdapter(
                          child: Text(
                            "$_selectedCategory Products",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      if (state is CatalogLoading)
                        const SliverFillRemaining(
                          child: Center(child: CircularProgressIndicator(color: Colors.orange)),
                        )
                      else if (state is CatalogLoaded)
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.72,
                            ),
                            delegate: SliverChildBuilderDelegate(
                                  (context, index) => _buildProductCard(context, state.products[index]),
                              childCount: state.products.length,
                            ),
                          ),
                        )
                      else if (state is CatalogError)
                          SliverFillRemaining(
                            child: Center(
                              child: Text(state.message, style: const TextStyle(color: Colors.red)),
                            ),
                          ),
                      const SliverToBoxAdapter(child: SizedBox(height: 80)),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- MODIFIED PRODUCT CARD WITH BOTTOM SHEET LOGIC ---
  Widget _buildProductCard(BuildContext context, Product product) {
    final String formattedPrice = NumberFormat.currency(
      locale: 'en_IN', symbol: '₹', decimalDigits: 0,
    ).format(product.price * 83);

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
          builder: (context) => ProductDetailPage(product: product))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: CachedNetworkImage(
                      imageUrl: product.thumbnail,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) => Container(color: Colors.grey[100]),
                      errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                    ),
                  ),
                  Positioned(
                    top: 8, right: 8,
                    child: BlocBuilder<FavoritesCubit, List<ProductModel>>(
                      builder: (context, favList) {
                        final isFav = context.read<FavoritesCubit>().isFavorite(product.id);
                        return GestureDetector(
                          onTap: () => context.read<FavoritesCubit>().toggleFavorite(product as ProductModel),
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.white.withOpacity(0.9),
                            child: Icon(isFav ? Icons.favorite : Icons.favorite_border,
                                size: 16, color: isFav ? Colors.red : Colors.orange),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(formattedPrice, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                      GestureDetector(
                        onTap: () {
                          // 1. Add to Cart
                          context.read<CartCubit>().addToCart(product as ProductModel);

                          // 2. 🟢 Show Professional Bottom Popup
                          _showAddToCartPopup(context, product);
                        },
                        child: const Icon(Icons.add_circle, size: 24, color: Colors.orange),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // 🛠️ Function to show the Bottom Sheet
  void _showAddToCartPopup(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 50),
              const SizedBox(height: 16),
              Text(
                "${product.title} added to cart!",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                "Would you like to continue shopping or proceed to payment?",
                style: TextStyle(color: Colors.grey, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  // Button: Keep Adding More Items
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Colors.orange),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Add More", style: TextStyle(color: Colors.orange)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Button: Go to Cart for Payment
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close Popup
                        // 🟢 Switch to Shopping Tab (Index 1)
                        context.read<NavigationCubit>().changeTab(1);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("View Cart", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ... (Rest of the widgets like SearchBar, PromoBanner remain same)
  Widget _buildCategoryList() {
    final categories = ['All', 'Beauty', 'Fragrances', 'Furniture', 'Groceries'];
    return SizedBox(
      height: 45,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedCategory = category);
                  context.read<CatalogCubit>().changeCategory(category);
                }
              },
              selectedColor: Colors.orange,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: Colors.grey[100],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
      child: TextField(
        onChanged: (val) {
          if (_debounce?.isActive ?? false) _debounce!.cancel();
          _debounce = Timer(const Duration(milliseconds: 500), () => context.read<CatalogCubit>().searchProducts(val));
        },
        decoration: const InputDecoration(
          hintText: 'Search products...',
          prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.orange, Colors.deepOrange]),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Row(
        children: [
          Expanded(child: Text("Flash Sale\n40% OFF",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
          Icon(Icons.bolt, color: Colors.white, size: 30),
        ],
      ),
    );
  }
}