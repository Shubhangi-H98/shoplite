import '../entities/product.dart';

abstract class ProductRepository {
  /// Fetches a list of products with pagination.
  Future<List<Product>> getProducts({int limit = 20, int skip = 0});

  /// Fetches products filtered by category.
  Future<List<Product>> getProductsByCategory(String category, {int limit = 20, int skip = 0});

  /// Searches products by title/keyword.
  Future<List<Product>> searchProducts(String query);
}