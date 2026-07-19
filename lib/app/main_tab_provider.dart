import 'package:flutter_riverpod/flutter_riverpod.dart';

final mainTabProvider = NotifierProvider<MainTabNotifier, int>(
  MainTabNotifier.new,
);

class MainTabNotifier extends Notifier<int> {
  static const homeIndex = 0;
  static const cartIndex = 2;

  @override
  int build() => homeIndex;

  void select(int index) => state = index;
  void showHome() => state = homeIndex;
  void showCart() => state = cartIndex;
}
