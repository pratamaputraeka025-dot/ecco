// lib/screens/product/product_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/models.dart';
import '../../providers/cart_provider.dart';
import '../../providers/review_provider.dart';
import '../../utils/app_theme.dart';
import '../cart/cart_screen.dart';
import '../../widgets/review_card.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    // Load reviews untuk produk ini
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewProvider>().fetchProductReviews(widget.product.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final reviewProvider = context.watch<ReviewProvider>();
    final isInCart = cart.isInCart(widget.product.id);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // ──────────────────────────────────────────────────────────
          // SLIVER APP BAR (dengan Hero animation)
          // ──────────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppTheme.primary,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: AppTheme.primary,
                  size: 18,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Stack(
                  children: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.shopping_cart_outlined,
                          color: AppTheme.primary,
                          size: 18,
                        ),
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CartScreen(),
                        ),
                      ),
                    ),
                    if (cart.itemCount > 0)
                      Positioned(
                        right: 4,
                        top: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            '${cart.itemCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'product-${widget.product.id}',
                child: CachedNetworkImage(
                  imageUrl: widget.product.imageUrl,
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Container(
                    height: 300,
                    color: Colors.grey.shade100,
                    child: const Icon(
                      Icons.image,
                      size: 80,
                      color: Colors.grey,
                    ),
                  ),
                  placeholder: (context, url) => Container(
                    height: 300,
                    color: Colors.grey.shade100,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.accent,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ──────────────────────────────────────────────────────────
          // BODY (Informasi Produk)
          // ──────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Category & Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.product.category,
                            style: const TextStyle(
                              color: AppTheme.accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: AppTheme.gold,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.product.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              ' (${reviewProvider.totalReviews} ulasan)',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Name
                    Text(
                      widget.product.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Price
                    Text(
                      AppConstants.formatPrice(widget.product.price),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accent,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Stock
                    Row(
                      children: [
                        Icon(
                          widget.product.stock > 0
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: widget.product.stock > 0
                              ? AppTheme.success
                              : Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.product.stock > 0
                              ? 'Stok tersedia (${widget.product.stock} unit)'
                              : 'Stok habis',
                          style: TextStyle(
                            color: widget.product.stock > 0
                                ? AppTheme.success
                                : Colors.red,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Divider
                    Divider(color: Colors.grey.shade100, thickness: 2),
                    const SizedBox(height: 16),

                    // Description
                    const Text(
                      'Deskripsi Produk',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.product.description,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        height: 1.6,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Quantity Selector
                    const Text(
                      'Jumlah',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _quantityButton(Icons.remove, () {
                          if (_quantity > 1) {
                            setState(() => _quantity--);
                          }
                        }),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            '$_quantity',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _quantityButton(Icons.add, () {
                          if (_quantity < widget.product.stock) {
                            setState(() => _quantity++);
                          }
                        }),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Total: ${AppConstants.formatPrice(widget.product.price * _quantity)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textMuted,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Add to Cart button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: widget.product.stock > 0
                            ? () {
                                if (_quantity > 1) {
                                  context
                                      .read<CartProvider>()
                                      .addMultipleToCart(widget.product, _quantity);
                                } else {
                                  context
                                      .read<CartProvider>()
                                      .addToCart(widget.product);
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${widget.product.name} ditambahkan ke keranjang!',
                                    ),
                                    backgroundColor: AppTheme.success,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    action: SnackBarAction(
                                      label: 'Lihat Keranjang',
                                      textColor: Colors.white,
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const CartScreen(),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                                setState(() {
                                  _quantity = 1;
                                });
                              }
                            : null,
                        icon: Icon(
                          isInCart ? Icons.shopping_cart : Icons.shopping_cart_outlined,
                        ),
                        label: Text(
                          widget.product.stock > 0
                              ? 'Tambah ke Keranjang'
                              : 'Stok Habis',
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Buy Now
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: widget.product.stock > 0
                            ? () {
                                if (_quantity > 1) {
                                  context
                                      .read<CartProvider>()
                                      .addMultipleToCart(widget.product, _quantity);
                                } else {
                                  context
                                      .read<CartProvider>()
                                      .addToCart(widget.product);
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const CartScreen(),
                                  ),
                                );
                              }
                            : null,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.accent,
                          side: const BorderSide(color: AppTheme.accent),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Beli Sekarang',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ──────────────────────────────────────────────────────
                    // SECTION REVIEW (Ulasan Pembeli)
                    // ──────────────────────────────────────────────────────
                    const Divider(color: AppTheme.textMuted, thickness: 0.5),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ulasan Pembeli',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (reviewProvider.totalReviews > 0)
                          TextButton(
                            onPressed: () {
                              // Scroll ke review (opsional)
                            },
                            child: const Text('Lihat Semua'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Review Loading State
                    if (reviewProvider.isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      ),

                    // Review Error State
                    if (reviewProvider.errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            reviewProvider.errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ),

                    // Review Empty State
                    if (!reviewProvider.isLoading &&
                        reviewProvider.reviews.isEmpty &&
                        reviewProvider.errorMessage == null)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            'Belum ada ulasan untuk produk ini',
                            style: TextStyle(color: AppTheme.textMuted),
                          ),
                        ),
                      ),

                    // Review Summary & List
                    if (!reviewProvider.isLoading &&
                        reviewProvider.reviews.isNotEmpty) ...[
                      // Rating Summary Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Average Rating
                            Column(
                              children: [
                                Text(
                                  reviewProvider.averageRating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: List.generate(5, (i) {
                                    final ratingInt =
                                        reviewProvider.averageRating.round();
                                    return Icon(
                                      i < ratingInt
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: AppTheme.gold,
                                      size: 16,
                                    );
                                  }),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${reviewProvider.totalReviews} ulasan',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 24),
                            // Rating Distribution
                            Expanded(
                              child: Column(
                                children: [
                                  for (int i = 5; i >= 1; i--)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 30,
                                            child: Text(
                                              '$i ★',
                                              style: const TextStyle(fontSize: 11),
                                            ),
                                          ),
                                          Expanded(
                                            child: LinearProgressIndicator(
                                              value: (reviewProvider.ratingCounts[
                                                          i] ??
                                                      0) /
                                                  reviewProvider.totalReviews,
                                              backgroundColor: Colors.grey.shade200,
                                              color: AppTheme.gold,
                                              minHeight: 6,
                                              borderRadius:
                                                  BorderRadius.circular(3),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          SizedBox(
                                            width: 40,
                                            child: Text(
                                              '${((reviewProvider.ratingCounts[i] ?? 0) / reviewProvider.totalReviews * 100).toInt()}%',
                                              style: const TextStyle(fontSize: 11),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // List Reviews
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: reviewProvider.reviews.length > 3
                            ? 3
                            : reviewProvider.reviews.length,
                        itemBuilder: (context, index) {
                          final review = reviewProvider.reviews[index];
                          return ReviewCard(review: review);
                        },
                      ),

                      // Tombol Lihat Semua (jika review lebih dari 3)
                      if (reviewProvider.reviews.length > 3)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Center(
                            child: TextButton(
                              onPressed: () {
                                // Navigasi ke halaman semua review
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Fitur lihat semua review akan datang',
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              child: const Text('Lihat Semua Ulasan →'),
                            ),
                          ),
                        ),
                    ],

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quantityButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}