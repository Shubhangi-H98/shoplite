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
}