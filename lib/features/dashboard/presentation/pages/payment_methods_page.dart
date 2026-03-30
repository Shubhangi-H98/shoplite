import 'package:flutter/material.dart';

class PaymentMethodsPage extends StatelessWidget {
  const PaymentMethodsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment Methods", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.money, color: Colors.orange),
            title: const Text("Cash on Delivery"),
            subtitle: Text(
                "Currently set as default",
                style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])
            ),
            trailing: const Icon(Icons.check_circle, color: Colors.green),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.payment, color: Colors.grey),
            title: const Text("Online Payment"),
            subtitle: Text(
                "Not configured",
                style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}