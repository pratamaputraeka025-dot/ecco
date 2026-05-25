// lib/providers/review_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import '../utils/supabase_config.dart';

class ReviewProvider extends ChangeNotifier {
  List<Review> _reviews = [];
  bool _isLoading = false;
  String? _errorMessage;
  double _averageRating = 0;
  Map<int, int> _ratingCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

  List<Review> get reviews => _reviews;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get averageRating => _averageRating;
  Map<int, int> get ratingCounts => _ratingCounts;
  int get totalReviews => _reviews.length;

  Future<void> fetchProductReviews(String productId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await supabase
          .from('reviews')
          .select('*, profiles(name, avatar_url)')
          .eq('product_id', productId)
          .order('created_at', ascending: false);

      _reviews = (data as List).map((row) => Review.fromMap(row)).toList();
      _calculateRatingStats();
    } catch (e) {
      _errorMessage = 'Gagal memuat review: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> canReview(String orderId, String productId) async {
    try {
      final result = await supabase
          .from('reviews')
          .select('id')
          .eq('order_id', orderId)
          .eq('product_id', productId)
          .maybeSingle();

      return result == null;
    } catch (e) {
      return false;
    }
  }

  Future<String?> submitReview({
    required String productId,
    required String orderId,
    required String buyerId,
    required int rating,
    required String comment,
    List<String> images = const [],
  }) async {
    try {
      final review = {
        'product_id': productId,
        'order_id': orderId,
        'buyer_id': buyerId,
        'rating': rating,
        'comment': comment,
        'images': images,
      };

      await supabase.from('reviews').insert(review);
      await fetchProductReviews(productId);
      return null;
    } on PostgrestException catch (e) {
      if (e.message.contains('duplicate')) {
        return 'Anda sudah memberikan review untuk produk ini';
      }
      return 'Gagal menambah review: ${e.message}';
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    }
  }

  Future<String?> updateReview(String reviewId, {
    required int rating,
    required String comment,
  }) async {
    try {
      await supabase
          .from('reviews')
          .update({
            'rating': rating,
            'comment': comment,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', reviewId);

      final review = _reviews.firstWhere((r) => r.id == reviewId);
      await fetchProductReviews(review.productId);
      return null;
    } catch (e) {
      return 'Gagal update review: $e';
    }
  }

  Future<String?> deleteReview(String reviewId) async {
    try {
      final review = _reviews.firstWhere((r) => r.id == reviewId);
      await supabase.from('reviews').delete().eq('id', reviewId);
      await fetchProductReviews(review.productId);
      return null;
    } catch (e) {
      return 'Gagal hapus review: $e';
    }
  }

  void _calculateRatingStats() {
    if (_reviews.isEmpty) {
      _averageRating = 0;
      _ratingCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
      return;
    }

    double sum = 0;
    _ratingCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

    for (var review in _reviews) {
      sum += review.rating;
      _ratingCounts[review.rating] = (_ratingCounts[review.rating] ?? 0) + 1;
    }

    _averageRating = sum / _reviews.length;
  }
}