import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../../../../catalog/data/models/product_model.dart';
import '../../../data/models/cart_item_model.dart';


class CartCubit extends Cubit<List<CartItem>> {
  final Box<CartItem> _cartBox = Hive.box<CartItem>('cart_box');

  CartCubit() : super([]) {
    _loadCart();
  }

  // 1. Load from Hive on Startup
  void _loadCart() {
    debugPrint("📥 [CartCubit] Loading persisted cart items...");
    emit(_cartBox.values.toList());
  }

  // 2. Add Item / Increase Quantity
  void addToCart(ProductModel product) {
    debugPrint("🛒 [CartCubit] Adding to cart: ${product.title}");
    final items = List<CartItem>.from(state);
    final index = items.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      items[index].quantity += 1;
      items[index].save(); // Hive update
    } else {
      final newItem = CartItem(product: product);
      items.add(newItem);
      _cartBox.add(newItem); // Hive add
    }
    emit(items);
  }

  // 3. Remove or Decrease Quantity
  void removeFromCart(int productId) {
    final items = List<CartItem>.from(state);
    final index = items.indexWhere((item) => item.product.id == productId);

    if (index >= 0) {
      if (items[index].quantity > 1) {
        items[index].quantity -= 1;
        items[index].save();
      } else {
        items[index].delete();
        items.removeAt(index);
      }
      emit(items);
    }
  }

  // 4. Total Calculation
  double get totalPrice => state.fold(0, (sum, item) => sum + (item.product.price * item.quantity));

  // 5. Clear Cart (After Success)
  void clearCart() {
    debugPrint("🗑️ [CartCubit] Clearing all items.");
    _cartBox.clear();
    emit([]);
  }
}