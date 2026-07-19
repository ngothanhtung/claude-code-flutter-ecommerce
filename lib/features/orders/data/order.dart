import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus { processing }

enum PaymentMethod { cod, demoCard }

class OrderItem {
  const OrderItem({
    required this.productId,
    required this.name,
    required this.unitPrice,
    required this.quantity,
  });

  final String productId;
  final String name;
  final double unitPrice;
  final int quantity;
  double get total => unitPrice * quantity;

  Map<String, Object> toJson() => {
    'productId': productId,
    'name': name,
    'unitPrice': unitPrice,
    'quantity': quantity,
  };

  static OrderItem? tryFromJson(Object? json) {
    if (json is! Map) return null;
    final productId = json['productId'];
    final name = json['name'];
    final price = json['unitPrice'];
    final quantity = json['quantity'];
    if (productId is! String ||
        name is! String ||
        price is! num ||
        quantity is! int ||
        quantity <= 0) {
      return null;
    }
    return OrderItem(
      productId: productId,
      name: name,
      unitPrice: price.toDouble(),
      quantity: quantity,
    );
  }
}

class StoreOrder {
  const StoreOrder({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
    required this.date,
    required this.status,
    required this.shippingAddress,
    required this.paymentMethod,
  });

  final String id;
  final String userId;
  final List<OrderItem> items;
  final double total;
  final DateTime date;
  final OrderStatus status;
  final String shippingAddress;
  final PaymentMethod paymentMethod;

  Map<String, Object> toJson() => {
    'id': id,
    'userId': userId,
    'items': items.map((item) => item.toJson()).toList(),
    'total': total,
    'date': date.toIso8601String(),
    'status': status.name,
    'shippingAddress': shippingAddress,
    'paymentMethod': paymentMethod.name,
  };

  Map<String, Object> toFirestore() => {
    'id': id,
    'userId': userId,
    'items': items.map((item) => item.toJson()).toList(),
    'productIds': items.map((item) => item.productId).toSet().toList(),
    'total': total,
    'createdAt': Timestamp.fromDate(date),
    'status': status.name,
    'shippingAddress': shippingAddress,
    'paymentMethod': paymentMethod.name,
  };

  static StoreOrder? tryFromJson(Object? json, {String? fallbackUserId}) {
    if (json is! Map) return null;
    final id = json['id'];
    final userId = json['userId'] ?? fallbackUserId;
    final rawItems = json['items'];
    final total = json['total'];
    final date = _dateFrom(json['createdAt'] ?? json['date']);
    final address = json['shippingAddress'];
    final status = OrderStatus.values
        .where((v) => v.name == json['status'])
        .firstOrNull;
    final payment = PaymentMethod.values
        .where((v) => v.name == json['paymentMethod'])
        .firstOrNull;
    if (id is! String ||
        userId is! String ||
        userId.isEmpty ||
        rawItems is! List ||
        total is! num ||
        date == null ||
        address is! String ||
        status == null ||
        payment == null) {
      return null;
    }
    final items = rawItems
        .map(OrderItem.tryFromJson)
        .whereType<OrderItem>()
        .toList();
    if (items.isEmpty) return null;
    return StoreOrder(
      id: id,
      userId: userId,
      items: items,
      total: total.toDouble(),
      date: date,
      status: status,
      shippingAddress: address,
      paymentMethod: payment,
    );
  }

  static DateTime? _dateFrom(Object? value) => switch (value) {
    Timestamp timestamp => timestamp.toDate(),
    String text => DateTime.tryParse(text),
    _ => null,
  };
}
