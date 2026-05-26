import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';

class WishlistProvider with ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  Set<String> _ids = {};
  String? _uid;

  Set<String> get wishlistIds => _ids;
  int get count => _ids.length;
  bool isWishlisted(String id) => _ids.contains(id);

  void setUser(String uid) { if (_uid != uid) { _uid = uid; loadWishlist(); } }

  Future<void> loadWishlist() async {
    if (_uid == null) return;
    final doc = await _db.collection(AppConstants.wishlistCollection).doc(_uid).get();
    if (doc.exists) _ids = Set<String>.from(doc.data()!['productIds'] ?? []);
    notifyListeners();
  }

  Future<void> toggleWishlist(String id) async {
    if (_ids.contains(id)) _ids.remove(id); else _ids.add(id);
    notifyListeners();
    if (_uid != null) await _db.collection(AppConstants.wishlistCollection)
        .doc(_uid).set({'productIds': _ids.toList()});
  }

  void clearWishlist() { _ids = {}; _uid = null; notifyListeners(); }
}
