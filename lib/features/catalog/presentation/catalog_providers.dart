import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/catalog_repository.dart';
import '../data/category.dart';
import '../data/product.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => const CatalogRepository(),
);
final productsProvider = Provider<List<Product>>(
  (ref) => ref.watch(catalogRepositoryProvider).allProducts,
);
final categoriesProvider = Provider<List<Category>>(
  (ref) => ref.watch(catalogRepositoryProvider).categories,
);
final productProvider = Provider.family<Product?, String>(
  (ref, id) => ref.watch(catalogRepositoryProvider).findById(id),
);
final categoryProductsProvider = Provider.family<List<Product>, String>(
  (ref, id) => ref.watch(catalogRepositoryProvider).byCategory(id),
);
final relatedProductsProvider = Provider.family<List<Product>, String>(
  (ref, productId) => ref.watch(catalogRepositoryProvider).relatedTo(productId),
);

final catalogSearchProvider = NotifierProvider<CatalogSearchNotifier, String>(
  CatalogSearchNotifier.new,
);

class CatalogSearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String value) => state = value;
  void clear() => state = '';
}

final searchResultsProvider = Provider<List<Product>>((ref) {
  final query = ref.watch(catalogSearchProvider);
  return ref.watch(catalogRepositoryProvider).search(query);
});
