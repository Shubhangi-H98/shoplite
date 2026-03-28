
import '../../../../core/network/api_client.dart';
import '../../data/models/product_model.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';


class ProductRepositoryImpl implements ProductRepository {
  final ApiClient apiClient;

  ProductRepositoryImpl(this.apiClient);

  @override
  Future<List<Product>> getProducts({int limit = 20, int skip = 0}) async {
    final response = await apiClient.get(
      '/products',
      queryParameters: {'limit': limit, 'skip': skip},
    );

    final List data = response.data['products'];
    return data.map((json) => ProductModel.fromJson(json)).toList();
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    final response = await apiClient.get(
      '/products/search',
      queryParameters: {'q': query},
    );

    final List data = response.data['products'];
    return data.map((json) => ProductModel.fromJson(json)).toList();
  }
}