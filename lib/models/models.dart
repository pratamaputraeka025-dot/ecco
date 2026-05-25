// lib/models/models.dart
import 'package:flutter/material.dart';

// ──────────────────────────────────────────────────────────────
// USER MODEL
// ──────────────────────────────────────────────────────────────
class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String role;
  final String? avatarUrl;
  final DateTime? birthDate;
  final String? gender;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.role,
    this.avatarUrl,
    this.birthDate,
    this.gender,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPembeli => role == 'pembeli';
  bool get isPenjual => role == 'penjual';

  String get avatarDisplay => avatarUrl ?? 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=FF6B2B&color=fff';
  String get genderLabel => gender == 'L' ? 'Laki-laki' : gender == 'P' ? 'Perempuan' : 'Tidak disebutkan';

  factory UserModel.fromMap(Map<String, dynamic> map, String email) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] as String,
      email: email,
      phone: map['phone'] as String? ?? '',
      address: map['address'] as String? ?? '',
      role: map['role'] as String? ?? 'pembeli',
      avatarUrl: map['avatar_url'] as String?,
      birthDate: map['birth_date'] != null ? DateTime.parse(map['birth_date'] as String) : null,
      gender: map['gender'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      if (name.isNotEmpty) 'name': name,
      if (phone.isNotEmpty) 'phone': phone,
      if (address.isNotEmpty) 'address': address,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (birthDate != null) 'birth_date': birthDate!.toIso8601String().split('T')[0],
      if (gender != null) 'gender': gender,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}

// ──────────────────────────────────────────────────────────────
// PRODUCT MODEL
// ──────────────────────────────────────────────────────────────
class Product {
  final String id;
  final String sellerId;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final double rating;
  final int stock;
  final bool isActive;

  const Product({
    required this.id,
    required this.sellerId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.rating,
    required this.stock,
    this.isActive = true,
  });

  int get ratingInt => rating.round();
  String get ratingStars => '⭐' * ratingInt + (rating % 1 >= 0.5 ? '½' : '');

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      sellerId: map['seller_id'] as String,
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      price: (map['price'] as num).toDouble(),
      imageUrl: map['image_url'] as String? ?? '',
      category: map['category'] as String,
      rating: (map['rating'] as num? ?? 0).toDouble(),
      stock: map['stock'] as int? ?? 0,
      isActive: map['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
    'seller_id': sellerId,
    'name': name,
    'description': description,
    'price': price,
    'image_url': imageUrl,
    'category': category,
    'stock': stock,
  };
}

// ──────────────────────────────────────────────────────────────
// CART ITEM MODEL
// ──────────────────────────────────────────────────────────────
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get totalPrice => product.price * quantity;
}

// ──────────────────────────────────────────────────────────────
// ORDER MODEL
// ──────────────────────────────────────────────────────────────
class Order {
  final String id;
  final String buyerId;
  final List<CartItem> items;
  final double totalAmount;
  final String status;
  final DateTime createdAt;
  final String paymentMethod;
  final String shippingAddress;
  final String shippingMethod;
  final String note;

  const Order({
    required this.id,
    required this.buyerId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.paymentMethod,
    required this.shippingAddress,
    required this.shippingMethod,
    this.note = '',
  });

  String get statusLabel {
    const labels = {
      'pending': 'Menunggu Konfirmasi',
      'confirmed': 'Dikonfirmasi',
      'processing': 'Diproses',
      'shipped': 'Dikirim',
      'delivered': 'Selesai',
      'cancelled': 'Dibatalkan',
    };
    return labels[status] ?? status;
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    List<CartItem> items = [];

    if (map.containsKey('order_items') && map['order_items'] is List) {
      items = (map['order_items'] as List).map((itemMap) {
        final productMap = itemMap['products'] as Map<String, dynamic>;
        final product = Product.fromMap(productMap);
        return CartItem(
          product: product,
          quantity: itemMap['quantity'] as int,
        );
      }).toList();
    }

    return Order(
      id: map['id'] as String,
      buyerId: map['buyer_id'] as String,
      items: items,
      totalAmount: (map['total_amount'] as num).toDouble(),
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      paymentMethod: map['payment_method'] as String,
      shippingAddress: map['shipping_address'] as String,
      shippingMethod: map['shipping_method'] as String,
      note: map['note'] as String? ?? '',
    );
  }
}

// ──────────────────────────────────────────────────────────────
// REVIEW MODEL
// ──────────────────────────────────────────────────────────────
class Review {
  final String id;
  final String productId;
  final String orderId;
  final String buyerId;
  final int rating;
  final String comment;
  final List<String> images;
  final bool isVerifiedPurchase;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? buyerName;
  final String? buyerAvatar;

  const Review({
    required this.id,
    required this.productId,
    required this.orderId,
    required this.buyerId,
    required this.rating,
    required this.comment,
    this.images = const [],
    this.isVerifiedPurchase = true,
    required this.createdAt,
    required this.updatedAt,
    this.buyerName,
    this.buyerAvatar,
  });

  String get ratingLabel {
    switch (rating) {
      case 1: return 'Sangat Buruk';
      case 2: return 'Buruk';
      case 3: return 'Cukup';
      case 4: return 'Baik';
      case 5: return 'Sangat Baik';
      default: return '';
    }
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'] as String,
      productId: map['product_id'] as String,
      orderId: map['order_id'] as String,
      buyerId: map['buyer_id'] as String,
      rating: map['rating'] as int,
      comment: map['comment'] as String? ?? '',
      images: (map['images'] as List?)?.cast<String>() ?? [],
      isVerifiedPurchase: map['is_verified_purchase'] as bool? ?? true,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      buyerName: (map['profiles'] as Map<String, dynamic>?)?['name'] as String?,
      buyerAvatar: (map['profiles'] as Map<String, dynamic>?)?['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'product_id': productId,
    'order_id': orderId,
    'buyer_id': buyerId,
    'rating': rating,
    'comment': comment,
    'images': images,
    'is_verified_purchase': isVerifiedPurchase,
  };
}