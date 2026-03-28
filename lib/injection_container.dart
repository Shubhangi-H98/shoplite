import 'package:get_it/get_it.dart';
import 'core/network/api_client.dart';
import 'features/catalog/domain/repositories/product_repository.dart';
import 'features/catalog/data/repositories/product_repository_impl.dart';
import 'features/catalog/presentation/cubit/catalog_cubit.dart';


final sl = GetIt.instance;

Future<void> init() async {

  // Cubit: Register as a Factory so a new instance is created every time
  sl.registerFactory(() => CatalogCubit(sl()));

  // Repository: Register as a LazySingleton (one instance for the whole app)
  sl.registerLazySingleton<ProductRepository>(
        () => ProductRepositoryImpl(sl()),
  );
  // Core: Registering ApiClient as a Singleton.
  sl.registerLazySingleton(() => ApiClient());

}