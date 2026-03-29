import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import 'catalog_state.dart';

class CatalogCubit extends Cubit<CatalogState> {
  final ProductRepository repository;

  int _currentSkip = 0;
  final int _limit = 10;
  List<Product> _allProducts = [];
  bool _isFetchingMore = false;
  bool _hasMoreData = true;
  String _selectedCategory = 'All';

  CatalogCubit(this.repository) : super(CatalogInitial());

  Future<void> fetchProducts({bool isInitial = true, String? category}) async {
    if (isInitial) {
      _currentSkip = 0;
      _allProducts = [];
      _hasMoreData = true;
      _selectedCategory = category ?? _selectedCategory;
      emit(CatalogLoading());
    }

    try {
      debugPrint("📡 [CatalogCubit] Fetching $_selectedCategory: Skip=$_currentSkip");

      List<Product> newProducts;

      // Category wise logic
      if (_selectedCategory == 'All') {
        newProducts = await repository.getProducts(limit: _limit, skip: _currentSkip);
      } else {
        newProducts = await repository.getProductsByCategory(
            _selectedCategory.toLowerCase(),
            limit: _limit,
            skip: _currentSkip
        );
      }

      if (newProducts.isEmpty || newProducts.length < _limit) {
        _hasMoreData = false;
      }

      _allProducts.addAll(newProducts);
      _currentSkip += _limit;

      emit(CatalogLoaded(products: List.from(_allProducts)));
      debugPrint("✅ [CatalogCubit] Total items: ${_allProducts.length}");
    } catch (e) {
      emit(CatalogError(e.toString()));
    }
  }

  Future<void> loadMore() async {
    if (_isFetchingMore || !_hasMoreData || state is CatalogLoading) return;
    _isFetchingMore = true;
    await fetchProducts(isInitial: false);
    _isFetchingMore = false;
  }

  void changeCategory(String category) {
    if (_selectedCategory == category) return;
    fetchProducts(isInitial: true, category: category);
  }

  Future<void> searchProducts(String query) async {
    if (query.isEmpty) return fetchProducts(isInitial: true);
    emit(CatalogLoading());
    try {
      final results = await repository.searchProducts(query);
      emit(CatalogLoaded(products: results));
    } catch (e) {
      emit(CatalogError(e.toString()));
    }
  }
}