// lib/providers/product_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import '../utils/supabase_config.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCategory = 'Semua';
  String _searchQuery = '';

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

final List<String> categories = [
  'Semua',
  'Sepeda Gunung (MTB)',
  'Sepeda Road Bike',
  'Sepeda Lipat',
  'Sepeda City/Urban',
  'Sepeda Anak',      // tambah
];

  List<Product> get filteredProducts {
    return _products.where((p) {
      final matchCat = _selectedCategory == 'Semua' || p.category == _selectedCategory;
      final matchSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.category.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCat && matchSearch;
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

  Future<void> fetchProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await supabase
          .from('products')
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false);

      _products = (data as List).map((row) => Product.fromMap(row)).toList();
    } on PostgrestException catch (e) {
      _errorMessage = 'Gagal memuat produk: ${e.message}';
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyProducts(String sellerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await supabase
          .from('products')
          .select()
          .eq('seller_id', sellerId)
          .order('created_at', ascending: false);

      _products = (data as List).map((row) => Product.fromMap(row)).toList();
    } on PostgrestException catch (e) {
      _errorMessage = 'Gagal memuat produk: ${e.message}';
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> addProduct(Product product) async {
    try {
      await supabase.from('products').insert(product.toMap());
      await fetchMyProducts(product.sellerId);
      return null;
    } on PostgrestException catch (e) {
      return 'Gagal menambah produk: ${e.message}';
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    }
  }

  Future<String?> updateProduct(String id, Map<String, dynamic> updates) async {
    try {
      updates['updated_at'] = DateTime.now().toIso8601String();
      await supabase.from('products').update(updates).eq('id', id);

      final idx = _products.indexWhere((p) => p.id == id);
      if (idx >= 0) {
        final data = await supabase.from('products').select().eq('id', id).single();
        _products[idx] = Product.fromMap(data);
        notifyListeners();
      }
      return null;
    } on PostgrestException catch (e) {
      return 'Gagal update produk: ${e.message}';
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    }
  }

  // Pastikan method deleteProduct di ProductProvider seperti ini:

Future<String?> deleteProduct(String id) async {
  try {
    // Hard delete - hapus permanent
    await supabase.from('products').delete().eq('id', id);
    
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
    
    return null;
  } on PostgrestException catch (e) {
    return 'Gagal hapus produk: ${e.message}';
  } catch (e) {
    return 'Terjadi kesalahan: $e';
  }
}
}