import 'package:flutter/foundation.dart';
import 'package:shoplite/features/catalog/domain/repositories/product_repository.dart';
import '../../../../core/network/api_client.dart';
import '../models/product_model.dart';
import '../../domain/entities/product.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ApiClient apiClient;

  ProductRepositoryImpl(this.apiClient);

  @override
  Future<List<Product>> getProducts({int limit = 20, int skip = 0}) async {
    debugPrint("🌐 [Repository] Fetching products (limit: $limit, skip: $skip)");
    try {
      final response = await apiClient.get(
        '/products',
        queryParameters: {'limit': limit, 'skip': skip},
      );

      final List data = response.data['products'];
      debugPrint("📦 [Repository] Successfully received ${data.length} items from API.");

      return data.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint("❌ [Repository] Failed to fetch products: $e");
      rethrow;
    }
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    debugPrint("🔍 [Repository] Executing search for query: '$query'");
    try {
      final response = await apiClient.get('/products/search?q=$query');
      final List data = response.data['products'];
      debugPrint("🎯 [Repository] Search returned ${data.length} results.");

      return data.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint("❌ [Repository] Search API failed: $e");
      throw Exception("Search failed: $e");
    }
  }
}