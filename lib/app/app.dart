import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/account/presentation/theme_mode_provider.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/catalog/presentation/category_products_screen.dart';
import '../features/catalog/presentation/product_detail_screen.dart';
import '../features/orders/presentation/checkout_screen.dart';
import '../features/orders/presentation/order_detail_screen.dart';
import '../features/orders/presentation/order_history_screen.dart';
import '../features/orders/presentation/order_success_screen.dart';
import '../features/reviews/presentation/review_product_screen.dart';
import '../features/wishlist/presentation/wishlist_screen.dart';
import '../features/main_screen.dart';
import 'theme.dart';

class EverydayStoreApp extends ConsumerWidget {
  const EverydayStoreApp({super.key, required this.initialRoute});
  final String initialRoute;

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Everyday Store',
    theme: buildStoreTheme(Brightness.light),
    darkTheme: buildStoreTheme(Brightness.dark),
    themeMode: ref.watch(themeModeProvider),
    initialRoute: initialRoute,
    routes: {
      LoginScreen.routeName: (_) => const LoginScreen(),
      RegisterScreen.routeName: (_) => const RegisterScreen(),
      MainScreen.routeName: (_) => const MainScreen(),
      CheckoutScreen.routeName: (_) => const CheckoutScreen(),
      WishlistScreen.routeName: (_) => const WishlistScreen(),
      OrderHistoryScreen.routeName: (_) => const OrderHistoryScreen(),
    },
    onGenerateRoute: (settings) {
      final id = settings.arguments;
      final child = switch (settings.name) {
        ProductDetailScreen.routeName when id is String => ProductDetailScreen(
          productId: id,
        ),
        CategoryProductsScreen.routeName when id is String =>
          CategoryProductsScreen(categoryId: id),
        OrderSuccessScreen.routeName when id is String => OrderSuccessScreen(
          orderId: id,
        ),
        OrderDetailScreen.routeName when id is String => OrderDetailScreen(
          orderId: id,
        ),
        ReviewProductScreen.routeName when id is ReviewScreenArgs =>
          ReviewProductScreen(args: id),
        _ => const _RouteNotFoundScreen(),
      };
      return MaterialPageRoute<void>(settings: settings, builder: (_) => child);
    },
  );
}

class _RouteNotFoundScreen extends StatelessWidget {
  const _RouteNotFoundScreen();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: const Center(child: Text('This page could not be found.')),
  );
}
