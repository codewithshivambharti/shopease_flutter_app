import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final String category;
  final List<String> images;
  final double rating;
  final int reviewCount;
  final int stock;
  final bool isFeatured;
  final bool isOnSale;
  final DateTime createdAt;

  Product({required this.id, required this.name, required this.description,
    required this.price, this.originalPrice, required this.category,
    required this.images, this.rating = 0.0, this.reviewCount = 0,
    required this.stock, this.isFeatured = false, this.isOnSale = false,
    required this.createdAt});

  double get discountPercentage => (originalPrice != null && originalPrice! > price)
      ? ((originalPrice! - price) / originalPrice! * 100).roundToDouble() : 0;

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id, name: d['name'] ?? '', description: d['description'] ?? '',
      price: (d['price'] ?? 0).toDouble(), originalPrice: d['originalPrice']?.toDouble(),
      category: d['category'] ?? '', images: List<String>.from(d['images'] ?? []),
      rating: (d['rating'] ?? 0).toDouble(), reviewCount: d['reviewCount'] ?? 0,
      stock: d['stock'] ?? 0, isFeatured: d['isFeatured'] ?? false,
      isOnSale: d['isOnSale'] ?? false,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name, 'description': description, 'price': price,
    'originalPrice': originalPrice, 'category': category, 'images': images,
    'rating': rating, 'reviewCount': reviewCount, 'stock': stock,
    'isFeatured': isFeatured, 'isOnSale': isOnSale,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}

class UserModel {
  final String uid, name, email;
  final String? phone, photoUrl;
  final List<Address> addresses;
  final DateTime createdAt;

  UserModel({required this.uid, required this.name, required this.email,
    this.phone, this.photoUrl, this.addresses = const [], required this.createdAt});

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id, name: d['name'] ?? '', email: d['email'] ?? '',
      phone: d['phone'], photoUrl: d['photoUrl'],
      addresses: (d['addresses'] as List<dynamic>?)?.map((a) => Address.fromMap(a)).toList() ?? [],
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name, 'email': email, 'phone': phone, 'photoUrl': photoUrl,
    'addresses': addresses.map((a) => a.toMap()).toList(),
    'createdAt': Timestamp.fromDate(createdAt),
  };
}

class Address {
  final String id, label, fullName, phone, addressLine1, city, state, pincode;
  final String? addressLine2;
  final bool isDefault;

  Address({required this.id, required this.label, required this.fullName,
    required this.phone, required this.addressLine1, this.addressLine2,
    required this.city, required this.state, required this.pincode, this.isDefault = false});

  factory Address.fromMap(Map<String, dynamic> m) => Address(
    id: m['id'] ?? '', label: m['label'] ?? 'Home', fullName: m['fullName'] ?? '',
    phone: m['phone'] ?? '', addressLine1: m['addressLine1'] ?? '',
    addressLine2: m['addressLine2'], city: m['city'] ?? '',
    state: m['state'] ?? '', pincode: m['pincode'] ?? '', isDefault: m['isDefault'] ?? false,
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'label': label, 'fullName': fullName, 'phone': phone,
    'addressLine1': addressLine1, 'addressLine2': addressLine2,
    'city': city, 'state': state, 'pincode': pincode, 'isDefault': isDefault,
  };

  String get fullAddress => '$addressLine1${addressLine2 != null ? ", $addressLine2" : ""}, $city, $state - $pincode';
}

class CartItem {
  final String productId, productName, productImage;
  final double price;
  int quantity;
  final String? selectedSize, selectedColor;

  CartItem({required this.productId, required this.productName,
    required this.productImage, required this.price, required this.quantity,
    this.selectedSize, this.selectedColor});

  double get totalPrice => price * quantity;

  factory CartItem.fromMap(Map<String, dynamic> m) => CartItem(
    productId: m['productId'] ?? '', productName: m['productName'] ?? '',
    productImage: m['productImage'] ?? '', price: (m['price'] ?? 0).toDouble(),
    quantity: m['quantity'] ?? 1, selectedSize: m['selectedSize'], selectedColor: m['selectedColor'],
  );

  Map<String, dynamic> toMap() => {
    'productId': productId, 'productName': productName, 'productImage': productImage,
    'price': price, 'quantity': quantity, 'selectedSize': selectedSize, 'selectedColor': selectedColor,
  };
}

class Order {
  final String id, userId, paymentId, paymentMethod;
  final List<CartItem> items;
  final double subtotal, deliveryCharge, discount, totalAmount;
  final Address deliveryAddress;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Order({required this.id, required this.userId, required this.items,
    required this.subtotal, required this.deliveryCharge, required this.discount,
    required this.totalAmount, required this.deliveryAddress, required this.status,
    required this.paymentId, required this.paymentMethod, required this.createdAt, this.updatedAt});

  factory Order.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Order(
      id: doc.id, userId: d['userId'] ?? '',
      items: (d['items'] as List<dynamic>?)?.map((i) => CartItem.fromMap(i)).toList() ?? [],
      subtotal: (d['subtotal'] ?? 0).toDouble(),
      deliveryCharge: (d['deliveryCharge'] ?? 0).toDouble(),
      discount: (d['discount'] ?? 0).toDouble(),
      totalAmount: (d['totalAmount'] ?? 0).toDouble(),
      deliveryAddress: Address.fromMap(d['deliveryAddress'] ?? {}),
      status: OrderStatus.values.firstWhere((e) => e.name == d['status'], orElse: () => OrderStatus.pending),
      paymentId: d['paymentId'] ?? '', paymentMethod: d['paymentMethod'] ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'items': items.map((i) => i.toMap()).toList(),
    'subtotal': subtotal, 'deliveryCharge': deliveryCharge,
    'discount': discount, 'totalAmount': totalAmount,
    'deliveryAddress': deliveryAddress.toMap(),
    'status': status.name, 'paymentId': paymentId, 'paymentMethod': paymentMethod,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
  };
}

enum OrderStatus { pending, confirmed, processing, shipped, delivered, cancelled, refunded }

extension OrderStatusX on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending: return 'Pending';
      case OrderStatus.confirmed: return 'Confirmed';
      case OrderStatus.processing: return 'Processing';
      case OrderStatus.shipped: return 'Shipped';
      case OrderStatus.delivered: return 'Delivered';
      case OrderStatus.cancelled: return 'Cancelled';
      case OrderStatus.refunded: return 'Refunded';
    }
  }
}
