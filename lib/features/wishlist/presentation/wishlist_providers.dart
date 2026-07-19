import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../catalog/presentation/catalog_providers.dart';
import '../data/wishlist_repository.dart';

final wishlistRepositoryProvider = Provider(
  (ref) => WishlistRepository(ref.watch(localStoreProvider)),
);
final wishlistProvider = NotifierProvider<WishlistNotifier, Set<String>>(
  WishlistNotifier.new,
);

class WishlistNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    final validIds = ref.read(productsProvider).map((p) => p.id).toSet();
    return ref.read(wishlistRepositoryProvider).load().intersection(validIds);
  }

  Future<void> toggle(String id) async {
    final next = {...state};
    next.contains(id) ? next.remove(id) : next.add(id);
    await ref.read(wishlistRepositoryProvider).save(next);
    state = next;
  }
}
