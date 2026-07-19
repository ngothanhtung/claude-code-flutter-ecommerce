import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/local_store.dart';
import 'order.dart';

abstract interface class OrderRepository {
  Stream<List<StoreOrder>> watchForUser(String userId);

  Future<void> add(StoreOrder order);
}

class FirestoreOrderRepository implements OrderRepository {
  FirestoreOrderRepository([FirebaseFirestore? firestore])
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Stream<List<StoreOrder>> watchForUser(String userId) => _firestore
      .collection('orders')
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map((snapshot) {
        final orders = snapshot.docs
            .map((document) => StoreOrder.tryFromJson(document.data()))
            .whereType<StoreOrder>()
            .toList();
        orders.sort((a, b) => b.date.compareTo(a.date));
        return orders;
      });

  @override
  Future<void> add(StoreOrder order) =>
      _firestore.collection('orders').doc(order.id).set(order.toFirestore());
}

/// Used by widget tests and the tutorial compatibility wrapper only.
class InMemoryOrderRepository implements OrderRepository {
  final List<StoreOrder> _orders = [];
  final StreamController<void> _changes = StreamController<void>.broadcast();

  @override
  Stream<List<StoreOrder>> watchForUser(String userId) async* {
    yield _forUser(userId);
    await for (final _ in _changes.stream) {
      yield _forUser(userId);
    }
  }

  List<StoreOrder> _forUser(String userId) {
    final result = _orders.where((order) => order.userId == userId).toList();
    result.sort((a, b) => b.date.compareTo(a.date));
    return result;
  }

  @override
  Future<void> add(StoreOrder order) async {
    final index = _orders.indexWhere((current) => current.id == order.id);
    if (index < 0) {
      _orders.add(order);
    } else {
      _orders[index] = order;
    }
    _changes.add(null);
  }
}

class LegacyLocalOrderStore {
  const LegacyLocalOrderStore(this.store);

  static const storageKey = 'orders';
  final LocalStore store;

  List<StoreOrder> loadForUser(String userId) =>
      store.readJson(storageKey, const <StoreOrder>[], (json) {
        if (json is! List) return const <StoreOrder>[];
        return json
            .map((item) => StoreOrder.tryFromJson(item, fallbackUserId: userId))
            .whereType<StoreOrder>()
            .toList();
      });

  Future<void> clear() => store.remove(storageKey);
}
