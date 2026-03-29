import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // New import

import 'core/network/api_client.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart'; // New import
import 'features/cart/cart/presentation/cubit/cart_cubit.dart';
import 'features/cart/presentation/cubit/favorites_cubit.dart';
import 'features/catalog/domain/repositories/product_repository.dart';
import 'features/catalog/data/repositories/product_repository_impl.dart';
import 'features/catalog/presentation/cubit/catalog_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerFactory(() => CatalogCubit(sl()));
  sl.registerFactory(() => AuthCubit(sl()));
  sl.registerFactory(() => CartCubit());
  sl.registerFactory(() => FavoritesCubit());


  sl.registerLazySingleton<ProductRepository>(
        () => ProductRepositoryImpl(sl()),
  );

  sl.registerLazySingleton(() => ApiClient());
  sl.registerLazySingleton(() => const FlutterSecureStorage());
}