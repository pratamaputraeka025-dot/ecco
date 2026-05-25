// lib/providers/cart_provider.dart
import 'package:flutter/material.dart';
import '../models/models.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;
  int get itemCount => _items.fold(0, (s, i) => s + i.quantity);
  double get totalAmount => _items.fold(0, (s, i) => s + i.totalPrice);

  double get shippingCost {
    if (totalAmount == 0) return 0;
    if (totalAmount >= 500000) return 0;
    return 20000;
  }

  double get grandTotal => totalAmount + shippingCost;

  void addToCart(Product product) {
    final i = _items.indexWhere((x) => x.product.id == product.id);
    if (i >= 0) {
      _items[i].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void addMultipleToCart(Product product, int quantity) {
    final i = _items.indexWhere((x) => x.product.id == product.id);
    if (i >= 0) {
      _items[i].quantity += quantity;
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _items.removeWhere((x) => x.product.id == productId);
    notifyListeners();
  }

  void decreaseQuantity(String productId) {
    final i = _items.indexWhere((x) => x.product.id == productId);
    if (i >= 0) {
      if (_items[i].quantity > 1) {
        _items[i].quantity--;
      } else {
        _items.removeAt(i);
      }
      notifyListeners();
    }
  }

  void increaseQuantity(String productId) {
    final i = _items.indexWhere((x) => x.product.id == productId);
    if (i >= 0) {
      _items[i].quantity++;
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  bool isInCart(String productId) => _items.any((x) => x.product.id == productId);
}