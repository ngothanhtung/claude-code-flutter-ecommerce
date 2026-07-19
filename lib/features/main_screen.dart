import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/main_tab_provider.dart';
import 'account/presentation/account_tab.dart';
import 'cart/presentation/cart_providers.dart';
import 'cart/presentation/cart_tab.dart';
import 'catalog/presentation/categories_tab.dart';
import 'catalog/presentation/home_tab.dart';
import 'notifications/presentation/notification_providers.dart';
import 'notifications/presentation/notifications_tab.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  static const routeName = '/main';

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  int _cartCount = 0;
  int _unreadCount = 0;
  ProviderContainer? _container;
  ProviderSubscription<int>? _cartSubscription;
  ProviderSubscription<int>? _notificationSubscription;
  ProviderSubscription<int>? _tabSubscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final container = ProviderScope.containerOf(context);
    if (identical(container, _container)) return;
    _cartSubscription?.close();
    _notificationSubscription?.close();
    _tabSubscription?.close();
    _container = container;
    _selectedIndex = container.read(mainTabProvider);
    _cartCount = container.read(cartTotalQuantityProvider);
    _unreadCount = container.read(unreadNotificationsProvider);
    _cartSubscription = container.listen<int>(cartTotalQuantityProvider, (
      _,
      next,
    ) {
      if (mounted) setState(() => _cartCount = next);
    });
    _notificationSubscription = container.listen<int>(
      unreadNotificationsProvider,
      (_, next) {
        if (mounted) setState(() => _unreadCount = next);
      },
    );
    _tabSubscription = container.listen<int>(mainTabProvider, (_, next) {
      if (mounted && next != _selectedIndex) {
        setState(() => _selectedIndex = next);
      }
    });
  }

  @override
  void dispose() {
    _cartSubscription?.close();
    _notificationSubscription?.close();
    _tabSubscription?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = <Widget>[
      const HomeTab(),
      const CategoriesTab(),
      CartTab(
        onContinueShopping: _container == null
            ? () {}
            : _container!.read(mainTabProvider.notifier).showHome,
      ),
      const NotificationsTab(),
      const AccountTab(),
    ];
    return Scaffold(
      body: tabs[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        height: 72,
        onDestinationSelected: (value) =>
            _container?.read(mainTabProvider.notifier).select(value),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: 'Categories',
          ),
          NavigationDestination(
            icon: _cartCount == 0
                ? const Icon(Icons.shopping_bag_outlined)
                : Badge(
                    key: const ValueKey('cart-badge'),
                    label: Text('$_cartCount'),
                    child: const Icon(Icons.shopping_bag_outlined),
                  ),
            selectedIcon: _cartCount == 0
                ? const Icon(Icons.shopping_bag_rounded)
                : Badge(
                    label: Text('$_cartCount'),
                    child: const Icon(Icons.shopping_bag_rounded),
                  ),
            label: 'Cart',
          ),
          NavigationDestination(
            icon: _unreadCount == 0
                ? const Icon(Icons.notifications_none_rounded)
                : Badge(
                    label: Text('$_unreadCount'),
                    child: const Icon(Icons.notifications_none_rounded),
                  ),
            selectedIcon: _unreadCount == 0
                ? const Icon(Icons.notifications_rounded)
                : Badge(
                    label: Text('$_unreadCount'),
                    child: const Icon(Icons.notifications_rounded),
                  ),
            label: 'Updates',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
