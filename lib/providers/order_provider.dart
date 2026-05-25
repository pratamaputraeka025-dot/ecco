// lib/providers/order_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import '../utils/supabase_config.dart';
import '../utils/app_theme.dart';

class OrderProvider extends ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _unreadNotifications = 0;
  List<Map<String, dynamic>> _notifications = [];
  String? _lastCheckedOrderId;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get unreadNotifications => _unreadNotifications;
  List<Map<String, dynamic>> get notifications => _notifications;

  String? _currentSellerId;

  // Cek notifikasi baru berdasarkan pesanan terbaru
  Future<void> checkNewNotifications(String sellerId) async {
    _currentSellerId = sellerId;
    
    try {
      // Ambil pesanan terbaru untuk seller ini
      final data = await supabase
          .from('orders')
          .select('*, order_items!inner(*, products!inner(*))')
          .eq('order_items.products.seller_id', sellerId)
          .order('created_at', ascending: false)
          .limit(10);

      final newOrders = data as List;
      
      if (newOrders.isEmpty) return;
      
      // Ambil ID pesanan terbaru
      final latestOrderId = newOrders.first['id'];
      
      // Jika ada pesanan baru sejak terakhir cek
      if (_lastCheckedOrderId != latestOrderId && _lastCheckedOrderId != null) {
        // Cari pesanan baru
        for (var order in newOrders) {
          final orderId = order['id'];
          final isAlreadyNotified = _notifications.any((n) => n['orderId'] == orderId);
          
          if (!isAlreadyNotified) {
            _notifications.insert(0, {
              'id': orderId,
              'title': 'Pesanan Baru! 🛒',
              'body': 'Ada pesanan baru dengan total ${AppConstants.formatPrice((order['total_amount'] as num).toDouble())}',
              'orderId': orderId,
              'timestamp': DateTime.now(),
              'isRead': false,
            });
            _unreadNotifications++;
          }
        }
        notifyListeners();
      }
      
      _lastCheckedOrderId = latestOrderId;
      
    } catch (e) {
      print('Error checking notifications: $e');
    }
  }

  // Load notifikasi saat pertama kali buka halaman
  Future<void> loadNotifications(String sellerId) async {
    _currentSellerId = sellerId;
    _notifications.clear();
    _unreadNotifications = 0;
    
    try {
      final data = await supabase
          .from('orders')
          .select('*, order_items!inner(*, products!inner(*))')
          .eq('order_items.products.seller_id', sellerId)
          .order('created_at', ascending: false)
          .limit(20);

      final orders = data as List;
      
      if (orders.isNotEmpty) {
        _lastCheckedOrderId = orders.first['id'];
        
        // Tampilkan 5 pesanan terbaru sebagai notifikasi
        for (var i = 0; i < (orders.length > 5 ? 5 : orders.length); i++) {
          final order = orders[i];
          _notifications.add({
            'id': order['id'],
            'title': i == 0 ? 'Pesanan Baru! 🛒' : 'Pesanan Masuk',
            'body': 'Pesanan dengan total ${AppConstants.formatPrice((order['total_amount'] as num).toDouble())}',
            'orderId': order['id'],
            'timestamp': DateTime.parse(order['created_at']),
            'isRead': false,
          });
        }
        _unreadNotifications = _notifications.length;
        notifyListeners();
      }
      
    } catch (e) {
      print('Error loading notifications: $e');
    }
  }

  void setSellerId(String sellerId) {
    _currentSellerId = sellerId;
  }

  void markNotificationAsRead(int index) {
    if (index < _notifications.length) {
      _notifications[index]['isRead'] = true;
      if (_unreadNotifications > 0) {
        _unreadNotifications--;
      }
      notifyListeners();
    }
  }

  void markAllNotificationsAsRead() {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i]['isRead'] = true;
    }
    _unreadNotifications = 0;
    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    _unreadNotifications = 0;
    notifyListeners();
  }

  Future<void> fetchMyOrders(String buyerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await supabase
          .from('orders')
          .select('*, order_items(*, products(*))')
          .eq('buyer_id', buyerId)
          .order('created_at', ascending: false);

      _orders = (data as List).map((row) => Order.fromMap(row)).toList();
    } catch (e) {
      _errorMessage = 'Gagal memuat pesanan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSellerOrders(String sellerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentSellerId = sellerId;
      
      final data = await supabase
          .from('orders')
          .select('*, order_items!inner(*, products!inner(*))')
          .eq('order_items.products.seller_id', sellerId)
          .order('created_at', ascending: false);

      _orders = (data as List).map((row) => Order.fromMap(row)).toList();
      
      // Load notifikasi setelah fetch orders
      await loadNotifications(sellerId);
      
    } catch (e) {
      _errorMessage = 'Gagal memuat pesanan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh notifikasi manual (saat pull to refresh)
  Future<void> refreshNotifications(String sellerId) async {
    await loadNotifications(sellerId);
    await fetchSellerOrders(sellerId);
  }

  Future<String?> createOrder({
    required String buyerId,
    required List<CartItem> items,
    required double totalAmount,
    required String shippingAddress,
    required String shippingMethod,
    required String paymentMethod,
    String note = '',
  }) async {
    try {
      final orderData = await supabase.from('orders').insert({
        'buyer_id': buyerId,
        'total_amount': totalAmount,
        'shipping_address': shippingAddress,
        'shipping_method': shippingMethod,
        'payment_method': paymentMethod,
        'note': note,
        'status': 'pending',
      }).select().single();

      final orderId = orderData['id'] as String;

      final orderItems = items.map((item) => {
        'order_id': orderId,
        'product_id': item.product.id,
        'quantity': item.quantity,
        'price': item.product.price,
      }).toList();

      await supabase.from('order_items').insert(orderItems);

      return orderId;
    } on PostgrestException catch (e) {
      return 'Error: ${e.message}';
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    }
  }

  Future<String?> updateOrderStatus(String orderId, String newStatus) async {
    try {
      final result = await supabase
          .from('orders')
          .update({'status': newStatus, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', orderId)
          .select()
          .single();

      final updated = Order.fromMap(result);
      final idx = _orders.indexWhere((o) => o.id == orderId);
      if (idx >= 0) {
        _orders[idx] = updated;
      }
      notifyListeners();
      return null;
    } on PostgrestException catch (e) {
      return 'Gagal update status: ${e.message}';
    } catch (e) {
      return 'Gagal update status: $e';
    }
  }
}