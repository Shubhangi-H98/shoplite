import 'package:get_it/get_it.dart';
import 'core/network/api_client.dart';
import 'features/catalog/domain/repositories/product_repository.dart';
import 'features/catalog/data/repositories/product_repository_impl.dart';


final sl = GetIt.instance;

Future<void> init() async {
  // Core: Registering ApiClient as a Singleton.
  sl.registerLazySingleton(() => ApiClient());

  // Features - Catalog: Repository registration.
  sl.registerLazySingleton<ProductRepository>(
        () => ProductRepositoryImpl(sl()),
  );
}