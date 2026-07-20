import '../../../core/api_client.dart';
import 'category.dart';
import 'product.dart';
import 'promo.dart';
import 'seed_data.dart';

class CatalogRepository {
  const CatalogRepository({
    this.allProducts = seedProducts,
    this.categories = seedCategories,
    this.promos = seedPromos,
  });

  final List<Product> allProducts;
  final List<Category> categories;
  final List<Promo> promos;

  static Future<CatalogRepository> fromApi(ApiClient api) async {
    final results = await Future.wait([
      api.get('/api/v1/catalog/products?page_size=100'),
      api.get('/api/v1/catalog/categories'),
      api.get('/api/v1/catalog/promos'),
    ]);
    final productsPayload = results[0] as Map<String, dynamic>;
    return CatalogRepository(
      allProducts: (productsPayload['items'] as List)
          .cast<Map<String, dynamic>>()
          .map(Product.fromJson)
          .toList(growable: false),
      categories: (results[1] as List)
          .cast<Map<String, dynamic>>()
          .map(Category.fromJson)
          .toList(growable: false),
      promos: (results[2] as List)
          .cast<Map<String, dynamic>>()
          .map(Promo.fromJson)
          .toList(growable: false),
    );
  }

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

  List<Product> relatedTo(String productId, {int limit = 4}) {
    final product = findById(productId);
    if (product == null || limit <= 0) return const [];

    return allProducts
        .where(
          (candidate) =>
              candidate.id != product.id &&
              candidate.categoryId == product.categoryId,
        )
        .take(limit)
        .toList(growable: false);
  }
}
