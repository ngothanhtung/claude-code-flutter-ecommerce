class CartItem {
  const CartItem({required this.productId, required this.quantity});

  final String productId;
  final int quantity;

  Map<String, Object> toJson() => {
    'productId': productId,
    'quantity': quantity,
  };

  static CartItem? tryFromJson(Object? json) {
    if (json case {
      'productId': final String id,
      'quantity': final int qty,
    } when id.isNotEmpty && qty > 0) {
      return CartItem(productId: id, quantity: qty);
    }
    return null;
  }

  CartItem copyWith({int? quantity}) =>
      CartItem(productId: productId, quantity: quantity ?? this.quantity);
}
