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
  OrderCubit() : super([]) {
    _loadOrdersFromHive();
  }

  void _loadOrdersFromHive() {
    final box = Hive.box('orders_box');
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

    final updatedOrders = [newOrder, ...state];
    emit(updatedOrders);

  }
}