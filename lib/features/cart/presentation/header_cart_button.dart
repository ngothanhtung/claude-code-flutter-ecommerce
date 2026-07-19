import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/main_tab_provider.dart';
import '../../main_screen.dart';
import 'cart_providers.dart';

class HeaderCartButton extends ConsumerWidget {
  const HeaderCartButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartTotalQuantityProvider);
    return IconButton(
      key: const ValueKey('header-cart-button'),
      tooltip: 'Open cart',
      onPressed: () {
        ref.read(mainTabProvider.notifier).showCart();
        Navigator.of(context).popUntil(
          (route) =>
              route.settings.name == MainScreen.routeName || route.isFirst,
        );
      },
      icon: cartCount == 0
          ? const Icon(Icons.shopping_bag_outlined)
          : Badge(
              label: Text('$cartCount'),
              child: const Icon(Icons.shopping_bag_outlined),
            ),
    );
  }
}
