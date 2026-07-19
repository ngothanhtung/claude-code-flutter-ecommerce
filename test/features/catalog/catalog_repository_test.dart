import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tutorials/features/catalog/data/catalog_repository.dart';

void main() {
  const repository = CatalogRepository();

  test('seed catalog has unique valid products across every category', () {
    final products = repository.allProducts;
    final categories = repository.categories;
    expect(products.length, inInclusiveRange(24, 30));
    expect(
      products.map((product) => product.id).toSet().length,
      products.length,
    );
    final categoryIds = categories.map((category) => category.id).toSet();
    expect(
      products.every((product) => categoryIds.contains(product.categoryId)),
      isTrue,
    );
    for (final category in categories) {
      expect(repository.byCategory(category.id), isNotEmpty);
    }
  });

  test('search trims and ignores case', () {
    expect(repository.search('  AIRflex  ').single.id, 'airflex-runner');
    expect(repository.search('not-in-catalog'), isEmpty);
  });

  test('related products share the category and exclude the current item', () {
    final related = repository.relatedTo('airflex-runner');

    expect(related, isNotEmpty);
    expect(related.length, lessThanOrEqualTo(4));
    expect(related.every((product) => product.categoryId == 'fitness'), isTrue);
    expect(related.any((product) => product.id == 'airflex-runner'), isFalse);
    expect(repository.relatedTo('not-in-catalog'), isEmpty);
  });
}
