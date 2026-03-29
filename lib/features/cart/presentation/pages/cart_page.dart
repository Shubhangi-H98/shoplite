import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../cart/presentation/cubit/cart_cubit.dart';
import '../../data/models/cart_item_model.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint("🛒 [CartPage] Building Cart UI with Offline Image Support.");
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("My Cart", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocBuilder<CartCubit, List<CartItem>>(
        builder: (context, state) {
          if (state.isEmpty) {
            return const Center(
              child: Text("Your cart is empty!", style: TextStyle(fontSize: 18, color: Colors.grey)),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.length,
                  itemBuilder: (context, index) => _buildCartItem(context, state[index]),
                ),
              ),
              _buildOrderSummary(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem item) {
    final double indianPrice = item.product.price * 83;
    final String formattedPrice = NumberFormat.currency(
      locale: 'en_IN', symbol: '₹', decimalDigits: 0,
    ).format(indianPrice);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          // Senior Logic: Using CachedNetworkImage for Offline Support
          Container(
            height: 80, width: 80,
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(15)),
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
                    _buildQtyBtn(Icons.remove, () {
                      context.read<CartCubit>().removeFromCart(item.product.id);
                    }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text("${item.quantity}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    _buildQtyBtn(Icons.add, () {
                      context.read<CartCubit>().addToCart(item.product);
                    }),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        debugPrint("🗑️ [CartPage] Removing ${item.product.title} from cart.");
                        context.read<CartCubit>().removeFromCart(item.product.id);
                      },
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

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 16),
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context) {
    final cartCubit = context.read<CartCubit>();
    final double total = cartCubit.totalPrice * 83;
    final String formattedTotal = NumberFormat.currency(
      locale: 'en_IN', symbol: '₹', decimalDigits: 0,
    ).format(total);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Amount", style: TextStyle(fontSize: 16, color: Colors.grey)),
              Text(formattedTotal, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                debugPrint("🧾 [Cart] Order Success. Clearing Hive items.");
                cartCubit.clearCart();
                Navigator.pushNamed(context, '/order-success');
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
}