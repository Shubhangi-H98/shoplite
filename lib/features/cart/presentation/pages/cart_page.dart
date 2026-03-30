import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../dashboard/presentation/cubit/navigation_cubit.dart';
import '../../cart/presentation/cubit/cart_cubit.dart';
import '../../data/models/cart_item_model.dart';
import 'checkout_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint("🛒 [CartPage] Building Cart UI with Order Breakdown.");

    // Theme check
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // Removed hardcoded white background to support theme
      appBar: AppBar(
        title: const Text("My Cart", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocBuilder<CartCubit, List<CartItem>>(
        builder: (context, state) {
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

                  ElevatedButton.icon(
                    onPressed: () => context.read<NavigationCubit>().changeTab(0),
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

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.length,
                  itemBuilder: (context, index) => _buildCartItem(context, state[index], isDark),
                ),
              ),
              _buildOrderSummary(context, isDark),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem item, bool isDark) {
    final double indianPrice = item.product.price * 83;
    final String formattedPrice = NumberFormat.currency(
      locale: 'en_IN', symbol: '₹', decimalDigits: 0,
    ).format(indianPrice);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      // Dynamic background color for items
      decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(20)
      ),
      child: Row(
        children: [
          Container(
            height: 80, width: 80,
            decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(15)
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CachedNetworkImage(
                imageUrl: item.product.thumbnail,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(formattedPrice, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildQtyBtn(Icons.remove, isDark, () {
                      context.read<CartCubit>().removeFromCart(item.product.id);
                    }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text("${item.quantity}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    _buildQtyBtn(Icons.add, isDark, () {
                      context.read<CartCubit>().addToCart(item.product);
                    }),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => context.read<CartCubit>().removeFromCart(item.product.id),
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, bool isDark, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8)
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, bool isDark) {
    final cartCubit = context.read<CartCubit>();
    final double subtotal = cartCubit.totalPrice * 83;
    final double deliveryCharge = subtotal > 500 ? 0 : 40;
    final double total = subtotal + deliveryCharge;

    final String formattedSubtotal = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(subtotal);
    final String formattedDelivery = deliveryCharge == 0 ? "FREE" : "₹$deliveryCharge";
    final String formattedTotal = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(total);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        children: [
          TextButton.icon(
            onPressed: () => context.read<NavigationCubit>().changeTab(0),
            icon: const Icon(Icons.add, color: Colors.blue),
            label: const Text("Add More Items", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          ),
          const Divider(),
          const SizedBox(height: 8),

          _buildSummaryRow("Subtotal", formattedSubtotal, isDark),
          const SizedBox(height: 8),

          _buildSummaryRow("Delivery Charges", formattedDelivery, isDark,
              valueColor: deliveryCharge == 0 ? Colors.green : null),
          const SizedBox(height: 12),

          const Divider(),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Amount", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(formattedTotal, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange)),
            ],
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (context.read<CartCubit>().state.isNotEmpty) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const CheckoutPage()));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text("Place Order", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isDark, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Text(
            value,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: valueColor ?? (isDark ? Colors.white : Colors.black)
            )
        ),
      ],
    );
  }
}