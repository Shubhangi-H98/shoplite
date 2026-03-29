import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../../../catalog/data/models/product_model.dart';

class FavoritesCubit extends Cubit<List<ProductModel>> {
  // Favorites ke liye alag box
  final Box<ProductModel> _favBox = Hive.box<ProductModel>('favorites_box');

  FavoritesCubit() : super([]) {
    _loadFavorites();
  }

  // 1. Load from Hive on Startup
  void _loadFavorites() {
    debugPrint("❤️ [FavoritesCubit] Loading persisted favorites...");
    emit(_favBox.values.toList());
  }

  // 2. Toggle Favorite (Add or Remove)
  void toggleFavorite(ProductModel product) {
    final currentFavs = List<ProductModel>.from(state);
    final index = currentFavs.indexWhere((p) => p.id == product.id);

    if (index >= 0) {
      debugPrint("💔 [FavoritesCubit] Removing from favorites: ${product.title}");
      _favBox.deleteAt(index); // Disk se delete
      currentFavs.removeAt(index);
    } else {
      debugPrint("❤️ [FavoritesCubit] Adding to favorites: ${product.title}");
      _favBox.add(product); // Disk par save
      currentFavs.add(product);
    }
    emit(currentFavs);
  }

  // Helper: Check if product is favorite
  bool isFavorite(int productId) {
    return state.any((p) => p.id == productId);
  }
}