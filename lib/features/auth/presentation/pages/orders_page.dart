import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../cart/presentation/cubit/order_cubit.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("My Order History", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
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
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("ID: ${order.orderId}",
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                          Text(formattedPrice,
                              style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                      const Divider(height: 24),

                      _buildDetailRow(Icons.location_on_outlined, "Address", order.address),
                      const SizedBox(height: 8),
                      _buildDetailRow(Icons.payment_outlined, "Payment", order.paymentMethod),
                      const SizedBox(height: 8),
                      _buildDetailRow(Icons.calendar_today_outlined, "Date",
                          DateFormat('dd MMM yyyy, hh:mm a').format(order.orderDate)),

                      const Divider(height: 24),

                      Text("Items (${order.items.length})",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: order.items.map((item) => Chip(
                          label: Text(item.product.title, style: const TextStyle(fontSize: 11)),
                          backgroundColor: Colors.orange[50],
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black, fontSize: 13),
              children: [
                TextSpan(text: "$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: value, style: const TextStyle(color: Colors.black87)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}