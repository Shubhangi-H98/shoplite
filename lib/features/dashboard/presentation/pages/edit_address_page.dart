import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EditAddressPage extends StatefulWidget {
  const EditAddressPage({super.key});

  @override
  State<EditAddressPage> createState() => _EditAddressPageState();
}

class _EditAddressPageState extends State<EditAddressPage> {
  final _controller = TextEditingController();
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadCurrentAddress();
  }

  _loadCurrentAddress() async {
    String? addr = await _storage.read(key: 'last_shipping_address');
    if (addr != null) _controller.text = addr;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Address")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 4,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "Enter full address"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _storage.write(key: 'last_shipping_address', value: _controller.text);
                Navigator.pop(context, true);
              },
              child: const Text("Save Address"),
            )
          ],
        ),
      ),
    );
  }
}