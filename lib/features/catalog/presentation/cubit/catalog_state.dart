import 'package:equatable/equatable.dart';
import '../../domain/entities/product.dart';

// Base class for all Catalog states.
abstract class CatalogState extends Equatable {
  const CatalogState();

  @override
  List<Object?> get props => [];
}

// Initial state before any action is taken.
class CatalogInitial extends CatalogState {}

// State shown while fetching data from the API.
class CatalogLoading extends CatalogState {}

// State shown when products are successfully loaded.
class CatalogLoaded extends CatalogState {
  final List<Product> products;
  final bool hasReachedMax;

  final bool isOffline;

  const CatalogLoaded({
    required this.products,
    this.hasReachedMax = false,
    this.isOffline = false,
  });

  @override
  List<Object?> get props => [products, hasReachedMax, isOffline];
}

// State shown when an error occurs.
class CatalogError extends CatalogState {
  final String message;
  const CatalogError(this.message);

  @override
  List<Object?> get props => [message];
}