import 'category.dart';
import 'product.dart';
import 'promo.dart';
import 'seed_data.dart';

class CatalogRepository {
  const CatalogRepository();

  List<Product> get allProducts => seedProducts;
  List<Category> get categories => seedCategories;
  List<Promo> get promos => seedPromos;

  Product? findById(String id) {
    for (final product in allProducts) {
      if (product.id == id) return product;
    }
    return null;
  }

  List<Product> search(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return allProducts;
    return allProducts
        .where((product) => product.name.toLowerCase().contains(normalized))
        .toList(growable: false);
  }

  List<Product> byCategory(String categoryId) => allProducts
      .where((product) => product.categoryId == categoryId)
      .toList(growable: false);
}
