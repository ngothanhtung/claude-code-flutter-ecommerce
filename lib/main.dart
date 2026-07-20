import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/api_client.dart';
import 'core/local_store.dart';
import 'core/providers.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/auth_providers.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/catalog/data/catalog_repository.dart';
import 'features/catalog/presentation/catalog_providers.dart';
import 'features/orders/data/order_repository.dart';
import 'features/orders/presentation/order_providers.dart';
import 'features/main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final store = LocalStore(preferences);
  final api = ApiClient(preferences);
  final authRepository = ApiAuthRepository(api);
  await authRepository.restoreSession();
  final catalogRepository = await CatalogRepository.fromApi(api);
  final initialRoute = authRepository.currentUser == null
      ? LoginScreen.routeName
      : MainScreen.routeName;
  runApp(
    ProviderScope(
      overrides: [
        localStoreProvider.overrideWithValue(store),
        apiClientProvider.overrideWithValue(api),
        authRepositoryProvider.overrideWithValue(authRepository),
        catalogRepositoryProvider.overrideWithValue(catalogRepository),
      ],
      child: EverydayStoreApp(initialRoute: initialRoute),
    ),
  );
}

/// Compatibility wrapper used by simple widget tests and tutorial embedders.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final Future<SharedPreferences> preferences =
      SharedPreferences.getInstance();

  @override
  Widget build(BuildContext context) => FutureBuilder<SharedPreferences>(
    future: preferences,
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const MaterialApp(home: SizedBox.shrink());
      }
      final store = LocalStore(snapshot.requireData);
      final api = ApiClient(snapshot.requireData);
      final authRepository = InMemoryAuthRepository();
      return ProviderScope(
        overrides: [
          localStoreProvider.overrideWithValue(store),
          apiClientProvider.overrideWithValue(api),
          authRepositoryProvider.overrideWithValue(authRepository),
          orderRepositoryProvider.overrideWithValue(InMemoryOrderRepository()),
        ],
        child: EverydayStoreApp(
          initialRoute: authRepository.currentUser == null
              ? LoginScreen.routeName
              : MainScreen.routeName,
        ),
      );
    },
  );
}
