import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PaymentMethodsPage extends StatelessWidget {
  const PaymentMethodsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment Methods")),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.money),
            title: const Text("Cash on Delivery"),
            subtitle: const Text("Currently set as default"),
            trailing: const Icon(Icons.check_circle, color: Colors.green),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text("Online Payment"),
            subtitle: const Text("Not configured"),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}