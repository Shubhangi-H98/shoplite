import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../cart/presentation/cubit/cart_cubit.dart';
import '../cubit/order_cubit.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _addressController = TextEditingController();
  final _storage = const FlutterSecureStorage();
  String _selectedPayment = 'Cash on Delivery';

  @override
  void initState() {
    super.initState();
    _loadSavedAddress();
  }

  Future<void> _loadSavedAddress() async {
    final savedAddress = await _storage.read(key: 'last_shipping_address');
    if (savedAddress != null) {
      setState(() {
        _addressController.text = savedAddress;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartCubit = context.read<CartCubit>();
    final total = cartCubit.totalPrice;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Checkout", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Address Section ---
            const Text("Shipping Address", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _addressController,
              maxLines: 3, // Multi-line address ke liye
              decoration: InputDecoration(
                hintText: "Flat No, Street, Landmark, Pincode...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                prefixIcon: const Icon(Icons.location_on_outlined, color: Colors.orange),
              ),
            ),

            const SizedBox(height: 30),

            // --- Payment Section ---
            const Text("Payment Method", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildPaymentOption("Cash on Delivery", Icons.money),
            _buildPaymentOption("Online Payment (Mock)", Icons.payment),

            const Spacer(),

            // --- Total Summary ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Payable:", style: TextStyle(fontSize: 16, color: Colors.grey)),
                Text("₹${(total * 83).toStringAsFixed(0)}",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange)),
              ],
            ),
            const SizedBox(height: 20),

            // --- Confirm Button ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  String address = _addressController.text.trim();
                  if (address.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please add a shipping address")));
                    return;
                  }

                  await _storage.write(key: 'last_shipping_address', value: address);

                  context.read<OrderCubit>().placeOrder(
                      cartCubit.state,
                      total,
                      address,
                      _selectedPayment
                  );

                  cartCubit.clearCart();
                  Navigator.pushNamedAndRemoveUntil(context, '/order-success', (route) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text("Confirm Order", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border.all(color: _selectedPayment == title ? Colors.orange : Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: _selectedPayment == title ? Colors.orange : Colors.grey),
        title: Text(title, style: TextStyle(fontWeight: _selectedPayment == title ? FontWeight.bold : FontWeight.normal)),
        trailing: Radio(
          value: title,
          groupValue: _selectedPayment,
          activeColor: Colors.orange,
          onChanged: (val) => setState(() => _selectedPayment = val.toString()),
        ),
      ),
    );
  }
}