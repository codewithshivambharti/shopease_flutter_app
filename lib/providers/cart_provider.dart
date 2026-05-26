import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import '../utils/constants.dart';

class CartProvider with ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  List<CartItem> _items = [];
  String? _uid;

  List<CartItem> get items => _items;
  int get itemCount => _items.fold(0, (s, i) => s + i.quantity);
  double get subtotal => _items.fold(0, (s, i) => s + i.totalPrice);
  double get deliveryCharge => subtotal > 499 ? 0 : 49;
  double get totalAmount => subtotal + deliveryCharge;
  bool isInCart(String id) => _items.any((i) => i.productId == id);

  void setUser(String uid) { if (_uid != uid) { _uid = uid; loadCart(); } }

  Future<void> loadCart() async {
    if (_uid == null) return;
    final doc = await _db.collection(AppConstants.cartsCollection).doc(_uid).get();
    if (doc.exists) _items = (doc.data()!['items'] as List).map((i) => CartItem.fromMap(i)).toList();
    notifyListeners();
  }

  Future<void> addToCart(CartItem item) async {
    final i = _items.indexWhere((e) => e.productId == item.productId);
    if (i >= 0) _items[i].quantity += item.quantity; else _items.add(item);
    notifyListeners(); await _save();
  }

  Future<void> removeFromCart(String id) async {
    _items.removeWhere((i) => i.productId == id);
    notifyListeners(); await _save();
  }

  Future<void> updateQuantity(String id, int qty) async {
    if (qty <= 0) { await removeFromCart(id); return; }
    final i = _items.indexWhere((e) => e.productId == id);
    if (i >= 0) { _items[i].quantity = qty; notifyListeners(); await _save(); }
  }

  Future<void> clearCart() async {
    _items = []; notifyListeners();
    if (_uid != null) await _db.collection(AppConstants.cartsCollection).doc(_uid).delete();
  }

  Future<void> _save() async {
    if (_uid == null) return;
    await _db.collection(AppConstants.cartsCollection).doc(_uid)
        .set({'items': _items.map((i) => i.toMap()).toList()});
  }
}
