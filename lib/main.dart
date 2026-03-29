import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/cart/cart/presentation/cubit/cart_cubit.dart';
import 'features/cart/data/models/cart_item_model.dart';
import 'features/cart/presentation/cubit/favorites_cubit.dart';
import 'features/cart/presentation/cubit/order_cubit.dart';
import 'features/cart/presentation/pages/order_success_page.dart';
import 'features/catalog/data/models/product_model.dart';
import 'features/catalog/presentation/cubit/catalog_cubit.dart';
import 'features/dashboard/presentation/cubit/navigation_cubit.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/splash/presentation/pages/splash_page.dart';
import 'injection_container.dart' as di;

Future<void> main() async {
  try {
    debugPrint("🚀 [Main] Application Bootstrap Sequence Started.");
    WidgetsFlutterBinding.ensureInitialized();

    debugPrint("🐝 [Main] Initializing Hive Database...");
    await Hive.initFlutter();

    Hive.registerAdapter(ProductModelAdapter());
    await Hive.openBox<ProductModel>('products_box');

    Hive.registerAdapter(CartItemAdapter()); // New Adapter
    await Hive.openBox<CartItem>('cart_box');

    await Hive.openBox<ProductModel>('favorites_box');

    debugPrint("🛠️ [Main] Initializing Dependency Injection Service...");
    await di.init();
    debugPrint("✅ [Main] Dependency Injection Initialized.");

    runApp(const MyApp());
  } catch (e, stack) {
    debugPrint("💥 [Main] FATAL ERROR during startup: $e");
    debugPrint("📄 [Main] StackTrace: $stack");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint("🎨 [MyApp] Building Widget Tree with BlocProviders.");

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<CatalogCubit>()..fetchProducts()),
        BlocProvider(create: (_) => di.sl<AuthCubit>()..checkAuthStatus()),
        BlocProvider(create: (context) => di.sl<CartCubit>()),
        BlocProvider(create: (context) => di.sl<FavoritesCubit>()),
        BlocProvider(create: (context) => NavigationCubit()),
        BlocProvider(create: (context) => OrderCubit()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ShopLite',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange, primary: Colors.orange),
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(backgroundColor: Colors.white, elevation: 0),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashPage(),
          '/login': (context) => const LoginPage(),
          '/dashboard': (context) => const DashboardPage(),
          '/order-success': (context) => const OrderSuccessPage(),
        },
        // Navigation tracking
        onGenerateRoute: (settings) {
          debugPrint("🛣️ [Navigator] Route requested: ${settings.name}");
          return null;
        },
      ),
    );
  }
}