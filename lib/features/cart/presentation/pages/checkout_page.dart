import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // --- Price Calculations ---
    final double subtotal = cartCubit.totalPrice * 83; // Product total in INR
    final double gstAmount = subtotal * 0.05; // 5% GST
    final double deliveryCharge = subtotal > 500 ? 0 : 40; // Free delivery above 500
    final double finalTotal = subtotal + gstAmount + deliveryCharge;

    final String formattedSubtotal = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(subtotal);
    final String formattedGst = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(gstAmount);
    final String formattedDelivery = deliveryCharge == 0 ? "FREE" : "₹$deliveryCharge";
    final String formattedFinalTotal = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(finalTotal);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Address Section ---
            const Text("Shipping Address", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _addressController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Flat No, Street, Landmark, Pincode...",
                filled: true,
                fillColor: isDark ? Colors.grey[900] : Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                ),
                prefixIcon: const Icon(Icons.location_on_outlined, color: Colors.orange),
              ),
            ),

            const SizedBox(height: 24),

            // --- Payment Section ---
            const Text("Payment Method", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildPaymentOption("Cash on Delivery", Icons.money, isDark),
            _buildPaymentOption("Online Payment (Mock)", Icons.payment, isDark),

            const SizedBox(height: 24),

            // --- Professional Bill Details Section ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.grey[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Bill Details", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildPriceRow("Item Total (Subtotal)", formattedSubtotal, isDark),
                  const SizedBox(height: 8),
                  _buildPriceRow("GST (5%)", formattedGst, isDark),
                  const SizedBox(height: 8),
                  _buildPriceRow("Delivery Charges", formattedDelivery, isDark,
                      valueColor: deliveryCharge == 0 ? Colors.green : null),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(thickness: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("To Pay", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(formattedFinalTotal,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

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

                  // Passing the Final Total (including GST & Delivery) to OrderCubit
                  context.read<OrderCubit>().placeOrder(
                      cartCubit.state,
                      finalTotal / 83, // Convert back to base currency if needed by Cubit logic
                      address,
                      _selectedPayment
                  );

                  cartCubit.clearCart();
                  Navigator.pushNamedAndRemoveUntil(context, '/order-success', (route) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text("Confirm Order", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, bool isDark, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700], fontSize: 14)),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: valueColor)),
      ],
    );
  }

  Widget _buildPaymentOption(String title, IconData icon, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        border: Border.all(
          color: _selectedPayment == title ? Colors.orange : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
        ),
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