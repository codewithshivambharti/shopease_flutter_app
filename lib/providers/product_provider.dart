import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import '../utils/constants.dart';

class ProductProvider with ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  List<Product> _all = [], _filtered = [];
  bool _loading = false;
  String _category = 'All', _query = '', _sort = 'newest';

  List<Product> get products => _filtered;
  List<Product> get featuredProducts =>
      _all.where((p) => p.isFeatured).toList();
  List<Product> get saleProducts => _all.where((p) => p.isOnSale).toList();
  bool get isLoading => _loading;
  String get selectedCategory => _category;
  String get sortBy => _sort;

  ProductProvider() {
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      _loading = true;
      notifyListeners();
      final snap = await _db
          .collection(AppConstants.productsCollection)
          .orderBy('createdAt', descending: true)
          .get();
      _all = snap.docs.map((d) => Product.fromFirestore(d)).toList();
      if (_all.isEmpty) await _seed();
      _applyFilters();
    } catch (e) {
      debugPrint('fetch: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void setCategory(String c) {
    _category = c;
    _applyFilters();
    notifyListeners();
  }

  void setSearchQuery(String q) {
    _query = q;
    _applyFilters();
    notifyListeners();
  }

  void setSortBy(String s) {
    _sort = s;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    var f = List<Product>.from(_all);
    if (_category != 'All')
      f = f.where((p) => p.category == _category).toList();
    if (_query.isNotEmpty)
      f = f
          .where((p) =>
              p.name.toLowerCase().contains(_query.toLowerCase()) ||
              p.description.toLowerCase().contains(_query.toLowerCase()))
          .toList();
    switch (_sort) {
      case 'price_low':
        f.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        f.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'rating':
        f.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      default:
        f.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    _filtered = f;
  }

  List<Product> getRelated(String category, String excludeId) => _all
      .where((p) => p.category == category && p.id != excludeId)
      .take(6)
      .toList();

  Future<void> _seed() async {
    final items = [
      {
        'name': 'Wireless Headphones',
        'description':
            'Premium noise-cancelling headphones with 30hr battery, crystal clear audio.',
        'price': 2499.0,
        'originalPrice': 3999.0,
        'category': 'Electronics',
        'images': [
          'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400'
        ],
        'rating': 4.5,
        'reviewCount': 128,
        'stock': 50,
        'isFeatured': true,
        'isOnSale': true
      },
      {
        'name': 'Running Shoes Pro',
        'description':
            'High-performance running shoes with advanced cushioning for long runs.',
        'price': 1799.0,
        'originalPrice': 2499.0,
        'category': 'Sports',
        'images': [
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400'
        ],
        'rating': 4.3,
        'reviewCount': 89,
        'stock': 30,
        'isFeatured': true,
        'isOnSale': true
      },
      {
        'name': 'Smartwatch Series X',
        'description':
            'Feature-packed smartwatch with GPS, health monitoring and 7-day battery.',
        'price': 4999.0,
        'originalPrice': 6999.0,
        'category': 'Electronics',
        'images': [
          'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400'
        ],
        'rating': 4.7,
        'reviewCount': 256,
        'stock': 20,
        'isFeatured': true,
        'isOnSale': true
      },
      {
        'name': 'Organic Face Serum',
        'description':
            'Natural Vitamin C serum with hyaluronic acid for brightening skin.',
        'price': 899.0,
        'originalPrice': 1299.0,
        'category': 'Beauty',
        'images': [
          'https://images.unsplash.com/photo-1571781926291-c477ebfd024b?w=400'
        ],
        'rating': 4.4,
        'reviewCount': 67,
        'stock': 100,
        'isFeatured': false,
        'isOnSale': true
      },
      {
        'name': 'Men Casual T-Shirt',
        'description': 'Premium cotton t-shirt, perfect for everyday wear.',
        'price': 499.0,
        'originalPrice': 799.0,
        'category': 'Fashion',
        'images': [
          'https://images.unsplash.com/photo-1503341455253-b2e723bb3dbb?w=400'
        ],
        'rating': 4.2,
        'reviewCount': 45,
        'stock': 200,
        'isFeatured': false,
        'isOnSale': true
      },
      {
        'name': 'Yoga Mat Premium',
        'description':
            'Extra thick non-slip yoga mat with alignment lines and carry strap.',
        'price': 1299.0,
        'originalPrice': 1799.0,
        'category': 'Sports',
        'images': [
          'https://images.unsplash.com/photo-1601925260368-ae2f83cf8b7f?w=400'
        ],
        'rating': 4.6,
        'reviewCount': 92,
        'stock': 75,
        'isFeatured': false,
        'isOnSale': false
      },
      {
        'name': 'Laptop Stand Adjustable',
        'description':
            'Ergonomic aluminum laptop stand, 6 height levels, fits all laptops.',
        'price': 1199.0,
        'originalPrice': null,
        'category': 'Electronics',
        'images': [
          'https://images.unsplash.com/photo-1593642632559-0c6d3fc62b89?w=400'
        ],
        'rating': 4.8,
        'reviewCount': 203,
        'stock': 60,
        'isFeatured': true,
        'isOnSale': false
      },
      {
        'name': 'Scented Candle Set',
        'description':
            '3 luxury soy wax candles - vanilla, lavender & sandalwood.',
        'price': 699.0,
        'originalPrice': 999.0,
        'category': 'Home & Living',
        'images': [
          'https://images.unsplash.com/photo-1602178894860-82d15aa5ccf1?w=400'
        ],
        'rating': 4.5,
        'reviewCount': 38,
        'stock': 150,
        'isFeatured': false,
        'isOnSale': true
      },
      {
        'name': 'The Art of Innovation',
        'description':
            'Bestselling book on creativity and design thinking by Tom Kelley.',
        'price': 349.0,
        'originalPrice': 499.0,
        'category': 'Books',
        'images': [
          'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=400'
        ],
        'rating': 4.9,
        'reviewCount': 312,
        'stock': 500,
        'isFeatured': true,
        'isOnSale': true
      },
      {
        'name': 'Wireless Charging Pad',
        'description': '15W fast wireless charger, Qi-compatible, slim design.',
        'price': 799.0,
        'originalPrice': 1099.0,
        'category': 'Electronics',
        'images': [
          'https://images.unsplash.com/photo-1586953208448-b95a79798f07?w=400'
        ],
        'rating': 4.3,
        'reviewCount': 76,
        'stock': 80,
        'isFeatured': false,
        'isOnSale': true
      },
    ];
    final batch = _db.batch();
    for (final item in items) {
      final ref = _db.collection(AppConstants.productsCollection).doc();
      batch.set(ref, {...item, 'createdAt': Timestamp.now()});
    }
    await batch.commit();
    final snap = await _db.collection(AppConstants.productsCollection).get();
    _all = snap.docs.map((d) => Product.fromFirestore(d)).toList();
  }
}
