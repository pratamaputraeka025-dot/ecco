// lib/providers/cart_provider.dart
import 'package:flutter/material.dart';
import '../models/models.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount => _items.fold(0, (sum, item) => sum + item.totalPrice);

  double get shippingCost {
    if (totalAmount == 0) return 0;
    if (totalAmount >= 500000) return 0; // Free shipping
    return 20000;
  }

  double get grandTotal => totalAmount + shippingCost;

  void addToCart(Product product) {
    final index = _items.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void decreaseQuantity(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void increaseQuantity(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  bool isInCart(String productId) {
    return _items.any((item) => item.product.id == productId);
  }
}

// lib/providers/product_provider.dart

class ProductProvider extends ChangeNotifier {
  String _selectedCategory = 'Semua';
  String _searchQuery = '';

  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  final List<Product> _products = [
    Product(
      id: 'p1',
      name: 'Sepatu Nike Air Max 270',
      description: 'Sepatu lari premium dengan teknologi Air Max untuk kenyamanan maksimal. Desain modern cocok untuk olahraga maupun casual.',
      price: 1299000,
      imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400',
      category: 'Sepatu',
      rating: 4.8,
      stock: 15,
    ),
    Product(
      id: 'p2',
      name: 'Kaos Polos Premium',
      description: 'Kaos polos berbahan katun combed 30s yang lembut dan nyaman. Tersedia dalam berbagai warna pilihan.',
      price: 149000,
      imageUrl: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400',
      category: 'Pakaian',
      rating: 4.5,
      stock: 50,
    ),
    Product(
      id: 'p3',
      name: 'Smartphone Samsung Galaxy A54',
      description: 'Smartphone flagship dengan kamera 50MP, layar AMOLED 6.4 inci, dan baterai 5000mAh yang tahan lama.',
      price: 5999000,
      imageUrl: 'https://images.unsplash.com/photo-1610945265064-0e34e5519bbf?w=400',
      category: 'Elektronik',
      rating: 4.7,
      stock: 8,
    ),
    Product(
      id: 'p4',
      name: 'Tas Ransel Laptop Anti-Air',
      description: 'Tas ransel multifungsi dengan kompartemen laptop hingga 15.6 inci, material anti-air, dan desain ergonomis.',
      price: 459000,
      imageUrl: 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400',
      category: 'Tas',
      rating: 4.6,
      stock: 20,
    ),
    Product(
      id: 'p5',
      name: 'Jam Tangan Casio Edifice',
      description: 'Jam tangan pria dengan material stainless steel, water resistant 100m, dan fitur chronograph.',
      price: 899000,
      imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400',
      category: 'Aksesoris',
      rating: 4.9,
      stock: 5,
    ),
    Product(
      id: 'p6',
      name: 'Headphone Sony WH-1000XM4',
      description: 'Headphone over-ear dengan teknologi noise cancelling terbaik, suara premium, dan baterai 30 jam.',
      price: 3799000,
      imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400',
      category: 'Elektronik',
      rating: 4.9,
      stock: 10,
    ),
    Product(
      id: 'p7',
      name: 'Celana Jeans Slim Fit',
      description: 'Celana jeans pria slim fit berbahan denim stretch berkualitas tinggi, nyaman dipakai seharian.',
      price: 359000,
      imageUrl: 'https://images.unsplash.com/photo-1542272604-787c3835535d?w=400',
      category: 'Pakaian',
      rating: 4.4,
      stock: 30,
    ),
    Product(
      id: 'p8',
      name: 'Sneakers Adidas Ultraboost',
      description: 'Sepatu lari dengan teknologi Boost untuk energi pengembalian maksimal, ringan dan responsif.',
      price: 1599000,
      imageUrl: 'https://images.unsplash.com/photo-1608231387042-66d1773070a5?w=400',
      category: 'Sepatu',
      rating: 4.8,
      stock: 12,
    ),
    Product(
      id: 'p9',
      name: 'Power Bank Anker 20000mAh',
      description: 'Power bank kapasitas besar dengan teknologi fast charging, kompatibel dengan semua perangkat USB.',
      price: 499000,
      imageUrl: 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400',
      category: 'Elektronik',
      rating: 4.7,
      stock: 25,
    ),
    Product(
      id: 'p10',
      name: 'Dompet Kulit Premium',
      description: 'Dompet pria berbahan kulit asli dengan banyak slot kartu dan desain minimalis yang elegan.',
      price: 279000,
      imageUrl: 'https://images.unsplash.com/photo-1627123424574-724758594e93?w=400',
      category: 'Aksesoris',
      rating: 4.6,
      stock: 18,
    ),
  ];

  List<String> get categories => [
    'Semua',
    'Elektronik',
    'Pakaian',
    'Sepatu',
    'Tas',
    'Aksesoris',
  ];

  List<Product> get filteredProducts {
    return _products.where((product) {
      final matchCategory = _selectedCategory == 'Semua' || product.category == _selectedCategory;
      final matchSearch = _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.category.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCategory && matchSearch;
    }).toList();
  }

  List<Product> get featuredProducts => _products.where((p) => p.rating >= 4.7).toList();

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}
