import '../../../core/local_store.dart';

class WishlistRepository {
  const WishlistRepository(this.store);

  static const storageKey = 'wishlist';
  final LocalStore store;

  Set<String> load() => store.readJson(storageKey, <String>{}, (json) {
    if (json is! List) return <String>{};
    return json.whereType<String>().where((id) => id.isNotEmpty).toSet();
  });

  Future<void> save(Set<String> ids) =>
      store.writeJson(storageKey, ids.toList()..sort());
}
