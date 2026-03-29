import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:shoplite/features/catalog/domain/repositories/product_repository.dart';
import '../../../../core/network/api_client.dart';
import '../models/product_model.dart';
import '../../domain/entities/product.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ApiClient apiClient;
  // Hive box reference for products
  final Box<ProductModel> productBox = Hive.box<ProductModel>('products_box');

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
      final List<ProductModel> remoteProducts = data.map((json) => ProductModel.fromJson(json)).toList();

      debugPrint("📦 [Repository] API Success. Received ${remoteProducts.length} items.");


      debugPrint("📥 [Repository] Updating local Hive cache...");
      await productBox.clear();
      await productBox.addAll(remoteProducts);
      debugPrint("✅ [Repository] Local cache updated successfully.");

      return remoteProducts;
    } catch (e) {
      debugPrint("❌ [Repository] Network error or API failed: $e");

      if (productBox.isNotEmpty) {
        debugPrint("📡 [Repository] Switching to OFFLINE MODE. Loading from Hive...");
        final cachedProducts = productBox.values.toList();
        debugPrint("📦 [Repository] Found ${cachedProducts.length} items in local cache.");
        return cachedProducts;
      } else {
        debugPrint("⚠️ [Repository] No Internet AND No Cache available.");
        rethrow;
      }
    }
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    debugPrint("🔍 [Repository] Executing search for: '$query'");
    try {
      final response = await apiClient.get('/products/search?q=$query');
      final List data = response.data['products'];

      final results = data.map((json) => ProductModel.fromJson(json)).toList();
      debugPrint("🎯 [Repository] Search successful. Found ${results.length} matches.");

      return results;
    } catch (e) {
      debugPrint("❌ [Repository] Search failed: $e");

      if (productBox.isNotEmpty) {
        debugPrint("🔎 [Repository] Filtering search results from local cache...");
        return productBox.values
            .where((p) => p.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
      throw Exception("Search service unavailable and no cache found.");
    }
  }

  @override
  Future<List<Product>> getProductsByCategory(String category, {int limit = 20, int skip = 0}) async {
    final response = await apiClient.get('/products/category/$category', queryParameters: {
      'limit': limit,
      'skip': skip,
    });
    return (response.data['products'] as List).map((e) => ProductModel.fromJson(e)).toList();
  }
}