import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../catalog/domain/entities/product.dart';
import '../../../catalog/presentation/cubit/catalog_cubit.dart';
import '../../../catalog/presentation/cubit/catalog_state.dart';
import '../../../product_detail/presentation/pages/product_detail_page.dart';
import '../../../splash/presentation/widgets/home_header.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    debugPrint("📦 [CatalogPage] Screen Initialized. Fetching initial products...");

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        debugPrint("📜 [CatalogPage] Reach at the end of list! Ready for Pagination.");
      }
    });
  }

  @override
  void dispose() {
    debugPrint("🗑️ [CatalogPage] Disposing controllers and timers.");
    _debounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount = screenWidth > 600 ? 4 : 2;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocBuilder<CatalogCubit, CatalogState>(
          builder: (context, state) {
            debugPrint("🎨 [CatalogPage] Rebuilding UI with State: ${state.runtimeType}");

            return CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  sliver: SliverToBoxAdapter(child: HomeHeader()),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  sliver: SliverToBoxAdapter(child: _buildSearchBar()),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader("Categories"),
                        const SizedBox(height: 12),
                        _buildCategoryList(),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  sliver: SliverToBoxAdapter(child: _buildPromoBanner()),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  sliver: SliverToBoxAdapter(child: _buildSectionHeader("Popular Product")),
                ),

                if (state is CatalogLoading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator(color: Colors.orange)),
                  )
                else if (state is CatalogLoaded)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(state.message, style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                const SliverToBoxAdapter(child: SizedBox(height: 30)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    final double indianPrice = product.price * 83;
    final String formattedPrice = NumberFormat.currency(
      locale: 'en_IN', symbol: '₹', decimalDigits: 0,
    ).format(indianPrice);

    return GestureDetector(
      onTap: () {
        debugPrint("🎯 [CatalogPage] Navigating to Detail: ${product.title} (ID: ${product.id})");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProductDetailPage(product: product)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Hero(
                      tag: 'product-${product.id}',
                      child: Image.network(product.thumbnail, fit: BoxFit.cover, width: double.infinity),
                    ),
                  ),
                  const Positioned(
                    top: 10, right: 10,
                    child: CircleAvatar(radius: 15, backgroundColor: Colors.white70, child: Icon(Icons.favorite_border, size: 18, color: Colors.orange)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(formattedPrice, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 16)),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.black, size: 24),
                        onPressed: () => debugPrint("🛒 [CatalogPage] Quick-add: ${product.title}"),
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

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(15)),
      child: TextField(
        onChanged: (value) {
          debugPrint("⌨️ [CatalogPage] Input detected: '$value'");
          if (_debounce?.isActive ?? false) _debounce!.cancel();
          _debounce = Timer(const Duration(milliseconds: 500), () {
            debugPrint("🔍 [CatalogPage] Executing Debounced Search for: '$value'");
            context.read<CatalogCubit>().searchProducts(value);
          });
        },
        decoration: const InputDecoration(
          hintText: 'Search for products...',
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          suffixIcon: Icon(Icons.tune, color: Colors.orange),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        TextButton(onPressed: () {}, child: const Text('See All', style: TextStyle(color: Colors.orange))),
      ],
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.orange, Colors.deepOrangeAccent]),
        borderRadius: BorderRadius.circular(25),
      ),
      child: const Row(
        children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Special Sale\nUp to 40% OFF', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text('Limited time offer', style: TextStyle(color: Colors.white70)),
          ])),
          Icon(Icons.bolt, size: 40, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildCategoryList() {
    final categories = ['All', 'Men', 'Women', 'Electronic', 'Jewelry'];
    return SizedBox(height: 45, child: ListView.builder(
      scrollDirection: Axis.horizontal, itemCount: categories.length,
      itemBuilder: (context, index) {
        final isSelected = index == 0;
        return Padding(padding: const EdgeInsets.only(right: 10), child: FilterChip(
          label: Text(categories[index]), selected: isSelected, onSelected: (val) {},
          selectedColor: Colors.orange, labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
          backgroundColor: Colors.grey[100], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      },
    ));
  }
}