import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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

      // 🟢 1. Check Network Connectivity Status
      bool isDeviceOffline = false;
      try {
        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult.every((result) => result == ConnectivityResult.none)) {
          isDeviceOffline = true;
        }
      } catch (_) {}

      // 2. Fetch Data (API or Cache)
      List<Product> newProducts;
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

      // 🟢 3. Emit Loaded State with Offline Flag
      emit(CatalogLoaded(
        products: List.from(_allProducts),
        isOffline: isDeviceOffline,
      ));

      debugPrint("✅ [CatalogCubit] Total items: ${_allProducts.length} | Offline: $isDeviceOffline");
    } catch (e) {
      emit(CatalogError(e.toString()));
    }
  }

  Future<void> loadMore() async {
    if (_isFetchingMore || !_hasMoreData || state is CatalogLoading || state is CatalogError) return;

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
      // Search is strictly API dependent, we assume online or local filter
      emit(CatalogLoaded(products: results, isOffline: false));
    } catch (e) {
      emit(CatalogError(e.toString()));
    }
  }
}