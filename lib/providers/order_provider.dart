import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../models/models.dart';
import '../utils/constants.dart';

class OrderProvider with ChangeNotifier {
  final _db = FirebaseFirestore.instance;

  List<Order> _orders = [];
  bool _loading = false;
  String? _uid;

  List<Order> get orders => _orders;
  bool get isLoading => _loading;

  void setUser(String uid) {
    if (_uid != uid) {
      _uid = uid;
      fetchOrders();
    }
  }

  Future<void> fetchOrders() async {
    if (_uid == null) return;
    try {
      _loading = true;
      notifyListeners();
      final snap = await _db
          .collection(AppConstants.ordersCollection)
          .where('userId', isEqualTo: _uid)
          .orderBy('createdAt', descending: true)
          .get();
      _orders = snap.docs.map((d) => Order.fromFirestore(d)).toList();
    } catch (e) {
      debugPrint('fetchOrders: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<String?> placeOrder({
    required List<CartItem> items,
    required double subtotal,
    required double deliveryCharge,
    required double discount,
    required double totalAmount,
    required Address deliveryAddress,
    required String paymentId,
    required String paymentMethod,
  }) async {
    if (_uid == null) return null;
    try {
      final order = Order(
        id: '',
        userId: _uid!,
        items: items,
        subtotal: subtotal,
        deliveryCharge: deliveryCharge,
        discount: discount,
        totalAmount: totalAmount,
        deliveryAddress: deliveryAddress,
        status: OrderStatus.confirmed,
        paymentId: paymentId,
        paymentMethod: paymentMethod,
        createdAt: DateTime.now(),
      );
      final ref = await _db
          .collection(AppConstants.ordersCollection)
          .add(order.toFirestore());
      await fetchOrders();
      return ref.id;
    } catch (e) {
      debugPrint('placeOrder: $e');
      return null;
    }
  }

  Future<void> cancelOrder(String id) async {
    try {
      await _db.collection(AppConstants.ordersCollection).doc(id).update({
        'status': OrderStatus.cancelled.name,
        'updatedAt': DateTime.now(),
      });
      await fetchOrders();
    } catch (e) {
      debugPrint('cancelOrder: $e');
    }
  }
}