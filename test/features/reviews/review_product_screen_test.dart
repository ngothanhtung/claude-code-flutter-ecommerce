import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tutorials/features/auth/data/auth_repository.dart';
import 'package:flutter_tutorials/features/auth/presentation/auth_providers.dart';
import 'package:flutter_tutorials/features/reviews/data/product_review.dart';
import 'package:flutter_tutorials/features/reviews/data/review_repository.dart';
import 'package:flutter_tutorials/features/reviews/presentation/review_product_screen.dart';
import 'package:flutter_tutorials/features/reviews/presentation/review_providers.dart';

class _FakeReviewRepository implements ReviewRepository {
  ProductReview? review;

  @override
  Future<ProductReview?> findUserReview({
    required String productId,
    required String userId,
  }) async => review;

  @override
  Future<void> saveReview(ProductReview review) async {
    this.review = review;
  }
}

void main() {
  testWidgets('loads and updates the signed-in user review', (tester) async {
    final auth = InMemoryAuthRepository();
    final user = await auth.login(
      InMemoryAuthRepository.demoEmail,
      InMemoryAuthRepository.demoPassword,
    );
    final reviews = _FakeReviewRepository()
      ..review = ProductReview(
        userId: user.id,
        userName: user.name,
        userEmail: user.email,
        productId: 'product-1',
        orderId: 'order-old',
        rating: 2,
        comment: 'Original review',
      );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          reviewRepositoryProvider.overrideWithValue(reviews),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: FilledButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const ReviewProductScreen(
                      args: ReviewScreenArgs(
                        productId: 'product-1',
                        productName: 'Everyday Sneakers',
                        orderId: 'order-new',
                      ),
                    ),
                  ),
                ),
                child: const Text('Open review'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open review'));
    await tester.pumpAndSettle();

    expect(find.text('Everyday Sneakers'), findsOneWidget);
    expect(find.text('Original review'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('review-star-4')));
    await tester.enterText(
      find.byKey(const ValueKey('review-comment-field')),
      'Comfortable and well made.',
    );
    await tester.tap(find.byKey(const ValueKey('submit-review-button')));
    await tester.pumpAndSettle();

    expect(find.text('Open review'), findsOneWidget);
    expect(reviews.review?.rating, 4);
    expect(reviews.review?.comment, 'Comfortable and well made.');
    expect(reviews.review?.productId, 'product-1');
    expect(reviews.review?.orderId, 'order-new');
    expect(reviews.review?.userId, user.id);
  });
}
