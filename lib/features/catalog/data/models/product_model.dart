import 'package:flutter/foundation.dart';
import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.title,
    required super.description,
    required super.price,
    required super.thumbnail,
    required super.rating,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    try {
      return ProductModel(
        id: json['id'],
        title: json['title'],
        description: json['description'] ?? '',
        price: (json['price'] as num).toDouble(),
        thumbnail: json['thumbnail'],
        rating: (json['rating'] as num).toDouble(),
      );
    } catch (e, stack) {
      debugPrint("💥 [ProductModel] Error parsing product JSON (ID: ${json['id']}): $e");
      debugPrint("📄 [ProductModel] StackTrace: $stack");
      rethrow;
    }
  }
}