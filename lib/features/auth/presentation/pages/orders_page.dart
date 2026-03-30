import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../cart/presentation/cubit/order_cubit.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Theme check
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Order History", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        // Removed hardcoded white background and black foreground
      ),
      body: BlocBuilder<OrderCubit, List<OrderModel>>(
        builder: (context, orders) {
          if (orders.isEmpty) {
            return const Center(
              child: Text("You haven't placed any orders yet.",
                  style: TextStyle(color: Colors.grey, fontSize: 16)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final String formattedPrice = NumberFormat.currency(
                locale: 'en_IN', symbol: '₹', decimalDigits: 0,
              ).format(order.totalAmount * 83);

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                // Card color follows theme
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              "ID: ${order.orderId}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.blue[200] : Colors.blueGrey
                              )
                          ),
                          Text(formattedPrice,
                              style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                      const Divider(height: 24),

                      _buildDetailRow(Icons.location_on_outlined, "Address", order.address, isDark),
                      const SizedBox(height: 8),
                      _buildDetailRow(Icons.payment_outlined, "Payment", order.paymentMethod, isDark),
                      const SizedBox(height: 8),
                      _buildDetailRow(Icons.calendar_today_outlined, "Date",
                          DateFormat('dd MMM yyyy, hh:mm a').format(order.orderDate), isDark),

                      const Divider(height: 24),

                      Text("Items (${order.items.length})",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: order.items.map((item) => Chip(
                          label: Text(item.product.title, style: const TextStyle(fontSize: 11)),
                          // Dynamic chip background
                          backgroundColor: isDark ? Colors.orange.withOpacity(0.2) : Colors.orange[50],
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          side: BorderSide.none,
                        )).toList(),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              // Base style uses theme's body medium text color
              style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 13
              ),
              children: [
                TextSpan(text: "$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                    text: value,
                    style: TextStyle(color: isDark ? Colors.grey[300] : Colors.black87)
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}