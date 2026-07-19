import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tutorials/app/app.dart';
import 'package:flutter_tutorials/core/local_store.dart';
import 'package:flutter_tutorials/core/providers.dart';
import 'package:flutter_tutorials/features/account/presentation/account_tab.dart';
import 'package:flutter_tutorials/features/auth/data/auth_repository.dart';
import 'package:flutter_tutorials/features/auth/presentation/login_screen.dart';
import 'package:flutter_tutorials/features/auth/presentation/auth_providers.dart';
import 'package:flutter_tutorials/features/cart/presentation/cart_providers.dart';
import 'package:flutter_tutorials/features/orders/data/order_repository.dart';
import 'package:flutter_tutorials/features/orders/presentation/order_providers.dart';
import 'package:flutter_tutorials/features/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('adds a product and completes checkout into order history', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final store = LocalStore(await SharedPreferences.getInstance());
    final auth = InMemoryAuthRepository();
    await auth.login(
      InMemoryAuthRepository.demoEmail,
      InMemoryAuthRepository.demoPassword,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStoreProvider.overrideWithValue(store),
          authRepositoryProvider.overrideWithValue(auth),
          orderRepositoryProvider.overrideWithValue(InMemoryOrderRepository()),
        ],
        child: const EverydayStoreApp(initialRoute: MainScreen.routeName),
      ),
    );
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(MainScreen)),
    );

    final productCard = find.byKey(
      const ValueKey('product-card-airflex-runner'),
    );
    await tester.ensureVisible(productCard);
    await tester.pumpAndSettle();
    await tester.tap(productCard);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('add-to-cart-button')));
    await tester.pumpAndSettle();
    expect(container.read(cartTotalQuantityProvider), 1);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 4));
    await tester.tap(find.text('Cart').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('checkout-button')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('checkout-button')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('recipient-field')),
      'Mai Tran',
    );
    await tester.enterText(
      find.byKey(const ValueKey('phone-field')),
      '0900000000',
    );
    await tester.enterText(
      find.byKey(const ValueKey('address-field')),
      '1 Main Street',
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('place-order-button')),
    );
    await tester.tap(find.byKey(const ValueKey('place-order-button')));
    await tester.pumpAndSettle();

    expect(find.text('Order confirmed'), findsOneWidget);
    expect(container.read(cartProvider), isEmpty);
    expect(container.read(ordersProvider).value, hasLength(1));
  });

  testWidgets('account dark-mode toggle changes the app theme', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final store = LocalStore(await SharedPreferences.getInstance());
    final auth = InMemoryAuthRepository();
    await auth.login(
      InMemoryAuthRepository.demoEmail,
      InMemoryAuthRepository.demoPassword,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStoreProvider.overrideWithValue(store),
          authRepositoryProvider.overrideWithValue(auth),
          orderRepositoryProvider.overrideWithValue(InMemoryOrderRepository()),
        ],
        child: const EverydayStoreApp(initialRoute: MainScreen.routeName),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Account').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('theme-mode-switch')));
    await tester.tap(find.byKey(const ValueKey('theme-mode-switch')));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.byType(AccountTab))).brightness,
      Brightness.dark,
    );
  });

  testWidgets('header cart opens cart from product detail', (tester) async {
    SharedPreferences.setMockInitialValues({
      'cart': '[{"productId":"airflex-runner","quantity":2}]',
    });
    final store = LocalStore(await SharedPreferences.getInstance());
    final auth = InMemoryAuthRepository();
    await auth.login(
      InMemoryAuthRepository.demoEmail,
      InMemoryAuthRepository.demoPassword,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStoreProvider.overrideWithValue(store),
          authRepositoryProvider.overrideWithValue(auth),
          orderRepositoryProvider.overrideWithValue(InMemoryOrderRepository()),
        ],
        child: const EverydayStoreApp(initialRoute: MainScreen.routeName),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('floating-cart-button')), findsNothing);
    expect(find.byKey(const ValueKey('header-cart-button')), findsNothing);

    final productCard = find.byKey(
      const ValueKey('product-card-airflex-runner'),
    );
    await tester.ensureVisible(productCard);
    await tester.tap(productCard);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('floating-cart-button')), findsNothing);
    expect(find.byKey(const ValueKey('header-cart-button')), findsOneWidget);
    expect(find.byKey(const ValueKey('product-thumbnail-0')), findsOneWidget);
    expect(find.byKey(const ValueKey('product-thumbnail-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('product-thumbnail-2')), findsOneWidget);
    expect(find.text('1 / 3'), findsOneWidget);

    await tester.fling(
      find.byKey(const ValueKey('product-gallery')),
      const Offset(-600, 0),
      1200,
    );
    await tester.pumpAndSettle();
    expect(find.text('2 / 3'), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(const ValueKey('product-thumbnail-2')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('product-thumbnail-2')));
    await tester.pumpAndSettle();
    expect(find.text('3 / 3'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('header-cart-button')));
    await tester.pumpAndSettle();

    expect(find.text('AirFlex Runner'), findsOneWidget);
    expect(find.text('Subtotal · \$240'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('cart-increment-airflex-runner')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Subtotal · \$360'), findsOneWidget);
    expect(find.byKey(const ValueKey('floating-cart-button')), findsNothing);
    expect(find.byKey(const ValueKey('header-cart-button')), findsNothing);
  });

  testWidgets('registration signs in the new local user', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final store = LocalStore(await SharedPreferences.getInstance());
    final auth = InMemoryAuthRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStoreProvider.overrideWithValue(store),
          authRepositoryProvider.overrideWithValue(auth),
          orderRepositoryProvider.overrideWithValue(InMemoryOrderRepository()),
        ],
        child: const EverydayStoreApp(initialRoute: LoginScreen.routeName),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey('login-secondary-button')),
    );
    await tester.tap(find.byKey(const ValueKey('login-secondary-button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('name-field')),
      'Mai Tran',
    );
    await tester.enterText(
      find.byKey(const ValueKey('email-field')),
      'mai@example.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('password-field')),
      'secret1',
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('register-primary-button')),
    );
    await tester.tap(find.byKey(const ValueKey('register-primary-button')));
    await tester.pumpAndSettle();
    expect(find.text('Good morning, Mai'), findsOneWidget);
    expect(auth.currentUser?.email, 'mai@example.com');
  });
}
