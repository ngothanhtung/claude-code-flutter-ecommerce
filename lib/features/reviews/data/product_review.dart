class ProductReview {
  const ProductReview({
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.productId,
    required this.orderId,
    required this.rating,
    required this.comment,
    this.createdAt,
    this.updatedAt,
  });

  final String userId;
  final String userName;
  final String userEmail;
  final String productId;
  final String orderId;
  final int rating;
  final String comment;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  static ProductReview? tryFromMap(
    Map<String, dynamic>? data, {
    String? fallbackUserId,
  }) {
    if (data == null) return null;
    final userId = data['user_id'] ?? data['userId'] ?? fallbackUserId;
    final userName = data['user_name'] ?? data['userName'];
    final userEmail = data['user_email'] ?? data['userEmail'];
    final productId = data['product_id'] ?? data['productId'];
    final orderId = data['order_id'] ?? data['orderId'] ?? '';
    final rating = data['rating'];
    final comment = data['comment'];
    if (userId is! String ||
        userName is! String ||
        userEmail is! String ||
        productId is! String ||
        orderId is! String ||
        rating is! int ||
        rating < 1 ||
        rating > 5 ||
        comment is! String) {
      return null;
    }
    return ProductReview(
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      productId: productId,
      orderId: orderId,
      rating: rating,
      comment: comment,
      createdAt: _dateFrom(data['created_at'] ?? data['createdAt']),
      updatedAt: _dateFrom(data['updated_at'] ?? data['updatedAt']),
    );
  }

  static DateTime? _dateFrom(Object? value) => switch (value) {
    String text => DateTime.tryParse(text),
    _ => null,
  };
}
