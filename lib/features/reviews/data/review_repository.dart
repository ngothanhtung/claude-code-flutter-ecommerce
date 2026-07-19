import 'package:cloud_firestore/cloud_firestore.dart';

import 'product_review.dart';

abstract interface class ReviewRepository {
  Future<ProductReview?> findUserReview({
    required String productId,
    required String userId,
  });

  Future<void> saveReview(ProductReview review);
}

class FirestoreReviewRepository implements ReviewRepository {
  FirestoreReviewRepository([FirebaseFirestore? firestore])
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _reviewReference(
    String productId,
    String userId,
  ) => _firestore
      .collection('products')
      .doc(productId)
      .collection('reviews')
      .doc(userId);

  @override
  Future<ProductReview?> findUserReview({
    required String productId,
    required String userId,
  }) async {
    final snapshot = await _reviewReference(productId, userId).get();
    return ProductReview.tryFromMap(snapshot.data());
  }

  @override
  Future<void> saveReview(ProductReview review) async {
    final reference = _reviewReference(review.productId, review.userId);
    final existing = await reference.get();
    final data = <String, Object?>{
      'userId': review.userId,
      'userName': review.userName,
      'userEmail': review.userEmail,
      'productId': review.productId,
      'orderId': review.orderId,
      'rating': review.rating,
      'comment': review.comment.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
      if (!existing.exists) 'createdAt': FieldValue.serverTimestamp(),
    };
    await reference.set(data, SetOptions(merge: true));
  }
}
