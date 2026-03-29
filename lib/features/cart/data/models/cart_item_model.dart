import 'package:hive/hive.dart';
import '../../../catalog/data/models/product_model.dart';

part 'cart_item_model.g.dart';

@HiveType(typeId: 1) // Unique ID for Cart
class CartItem extends HiveObject {
  @HiveField(0)
  final ProductModel product;

  @HiveField(1)
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}