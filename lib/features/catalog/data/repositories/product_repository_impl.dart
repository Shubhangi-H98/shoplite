import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shoplite/features/catalog/domain/repositories/product_repository.dart';
import '../../../../core/network/api_client.dart';
import '../models/product_model.dart';
import '../../domain/entities/product.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ApiClient apiClient;
  final Box<ProductModel> productBox = Hive.box<ProductModel>('products_box');
  final _storage = const FlutterSecureStorage();

  ProductRepositoryImpl(this.apiClient);

  @override
  Future<List<Product>> getProducts({int limit = 20, int skip = 0}) async {
    debugPrint("🌐 [Repository] Fetching products (limit: $limit, skip: $skip)");

    // 🟢 1. SAFE CACHE STRATEGY (Wrapped in try-catch)
    try {
      final lastFetchStr = await _storage.read(key: 'catalog_last_fetch');
      if (lastFetchStr != null && productBox.isNotEmpty) {
        final lastFetchTime = DateTime.parse(lastFetchStr);
        final differenceMins = DateTime.now().difference(lastFetchTime).inMinutes;

        if (differenceMins < 30) {
          debugPrint("⏳ [Repository] Cache is fresh ($differenceMins mins old). Serving local data.");

          final cachedSlice = productBox.values.skip(skip).take(limit).toList();
          if (cachedSlice.isNotEmpty) return cachedSlice;
        }
      }
    } catch (e) {
      debugPrint("⚠️ [Repository] Hive Cache Read Error: $e. Proceeding to Network.");
      if (skip == 0) await productBox.clear();
    }

    // 🟢 2. NETWORK CALL
    try {
      final response = await apiClient.get(
        '/products',
        queryParameters: {'limit': limit, 'skip': skip},
      );

      final data = response.data['products'];
      if (data == null) return []; // Safe null check

      final List<ProductModel> remoteProducts = [];
      for (var json in data) {
        try {
          remoteProducts.add(ProductModel.fromJson(json));
        } catch (e) {
          debugPrint("⚠️ Skipping corrupted product item: $e");
        }
      }

      if (skip == 0) {
        await productBox.clear();
        await productBox.addAll(remoteProducts);
        await _storage.write(key: 'catalog_last_fetch', value: DateTime.now().toIso8601String());
      } else {
        await productBox.addAll(remoteProducts);
      }

      return remoteProducts;
    } catch (e) {
      debugPrint("❌ [Repository] Network error: $e");

      // 🟢 3. SAFE OFFLINE FALLBACK
      try {
        if (productBox.isNotEmpty) {
          final offlineData = productBox.values.skip(skip).take(limit).toList();
          if (offlineData.isNotEmpty) return offlineData;
        }
      } catch (_) {}

      return [];
    }
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await apiClient.get('/products/search?q=$query');
      final List data = response.data['products'];
      return data.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      try {
        if (productBox.isNotEmpty) {
          return productBox.values
              .where((p) => p.title.toLowerCase().contains(query.toLowerCase()))
              .toList();
        }
      } catch (_) {}
      return [];
    }
  }
  @override
  Future<List<Product>> getProductsByCategory(String category, {int limit = 20, int skip = 0}) async {
    try {
      // 1. ONLINE MODE: API Call
      final response = await apiClient.get('/products/category/$category', queryParameters: {
        'limit': limit,
        'skip': skip
      });

      final data = response.data['products'];
      if (data == null) return [];

      return (data as List).map((e) => ProductModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint("❌ [Repository] Category API failed: $e");

      try {
        if (productBox.isNotEmpty) {
          debugPrint("📡 [Repository] OFFLINE MODE. Perfect filtering for: $category");

          final offlineCategoryData = productBox.values
              .where((p) => p.category?.toLowerCase() == category.toLowerCase()) // 🟢 Exact Match!
              .skip(skip)
              .take(limit)
              .toList();

          return offlineCategoryData;
        }
      } catch (_) {}

      return [];
    }
  }
}