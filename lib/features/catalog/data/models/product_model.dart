import 'package:hive/hive.dart';
import '../../domain/entities/product.dart';
part 'product_model.g.dart';

@HiveType(typeId: 0) // Unique ID for Hive
class ProductModel extends Product {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final double price;

  @HiveField(4)
  final String thumbnail;

  @HiveField(5)
  final double rating;

  const ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.thumbnail,
    required this.rating,
  }) : super(
    id: id,
    title: title,
    description: description,
    price: price,
    thumbnail: thumbnail,
    rating: rating,
  );

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      price: (json['price'] as num).toDouble(),
      thumbnail: json['thumbnail'],
      rating: (json['rating'] as num).toDouble(),
    );
  }
}