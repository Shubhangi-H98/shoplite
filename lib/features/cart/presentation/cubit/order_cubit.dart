import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/cart_item_model.dart';

class OrderModel {
  final String orderId;
  final List<CartItem> items;
  final double totalAmount;
  final DateTime orderDate;
  final String address;
  final String paymentMethod;

  OrderModel({
    required this.orderId,
    required this.items,
    required this.totalAmount,
    required this.orderDate,
    required this.address,
    required this.paymentMethod,
  });
}

class OrderCubit extends Cubit<List<OrderModel>> {
  final Box _box = Hive.box('orders_box');

  OrderCubit() : super([]) {
    _loadOrdersFromHive();
  }

  void _loadOrdersFromHive() {
    final List<dynamic> rawOrders = _box.values.toList();
    if (rawOrders.isNotEmpty) {
      emit(rawOrders.cast<OrderModel>().reversed.toList());
    }
  }

  void placeOrder(List<CartItem> cartItems, double total, String address, String payment) {
    final newOrder = OrderModel(
      orderId: "ORD${DateTime.now().millisecondsSinceEpoch}",
      items: List.from(cartItems),
      totalAmount: total,
      orderDate: DateTime.now(),
      address: address,
      paymentMethod: payment,
    );

    _box.add(newOrder);

    final updatedOrders = [newOrder, ...state];
    emit(updatedOrders);
  }
}