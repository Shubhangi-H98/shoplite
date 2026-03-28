import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/product_repository.dart';
import 'catalog_state.dart';

class CatalogCubit extends Cubit<CatalogState> {
  final ProductRepository repository;

  CatalogCubit(this.repository) : super(CatalogInitial());

  // Function to fetch products
  Future<void> fetchProducts() async {
    emit(CatalogLoading());
    try {
      final products = await repository.getProducts();
      emit(CatalogLoaded(products: products));
    } catch (e) {
      emit(CatalogError(e.toString()));
    }
  }
  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      return fetchProducts(); // Reset to default products
    }

    emit(CatalogLoading());
    try {
      final results = await repository.searchProducts(query);
      if (results.isEmpty) {
        emit(CatalogError("No products found for '$query'"));
      } else {
        emit(CatalogLoaded(products: results));
      }
    } catch (e) {
      emit(CatalogError(e.toString()));
    }
  }
}