import '../../../core/api_client.dart';
import 'product_review.dart';

abstract interface class ReviewRepository {
  Future<ProductReview?> findUserReview({
    required String productId,
    required String userId,
  });

  Future<void> saveReview(ProductReview review);
}

class ApiReviewRepository implements ReviewRepository {
  ApiReviewRepository(this.api);

  final ApiClient api;

  @override
  Future<ProductReview?> findUserReview({
    required String productId,
    required String userId,
  }) async {
    final data = await api.get(
      '/api/v1/products/$productId/reviews/me',
      authenticated: true,
    );
    return data is Map<String, dynamic>
        ? ProductReview.tryFromMap(data, fallbackUserId: userId)
        : null;
  }

  @override
  Future<void> saveReview(ProductReview review) async {
    await api.put(
      '/api/v1/products/${review.productId}/reviews/me',
      authenticated: true,
      body: {'rating': review.rating, 'comment': review.comment.trim()},
    );
  }
}
