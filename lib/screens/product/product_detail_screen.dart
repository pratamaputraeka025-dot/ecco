// lib/screens/product/product_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../utils/app_theme.dart';
import '../cart/cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final isInCart = cart.isInCart(widget.product.id);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
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
                child: const Icon(Icons.arrow_back_ios_new, color: AppTheme.primary, size: 18),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.shopping_cart_outlined, color: AppTheme.primary, size: 18),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'product-${widget.product.id}',
                child: Image.network(
                  widget.product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade100,
                    child: const Icon(Icons.image, size: 80, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category & Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.product.category,
                            style: const TextStyle(color: AppTheme.accent, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star, color: AppTheme.gold, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              widget.product.rating.toString(),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(' (${(widget.product.rating * 100).toInt()} ulasan)',
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Name
                    Text(
                      widget.product.name,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    ),
                    const SizedBox(height: 8),

                    // Price
                    Text(
                      AppConstants.formatPrice(widget.product.price),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.accent),
                    ),
                    const SizedBox(height: 16),

                    // Stock
                    Row(
                      children: [
                        Icon(
                          widget.product.stock > 0 ? Icons.check_circle : Icons.cancel,
                          color: widget.product.stock > 0 ? AppTheme.success : Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.product.stock > 0
                              ? 'Stok tersedia (${widget.product.stock} unit)'
                              : 'Stok habis',
                          style: TextStyle(
                            color: widget.product.stock > 0 ? AppTheme.success : Colors.red,
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
                    const Text('Deskripsi Produk', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      widget.product.description,
                      style: TextStyle(color: Colors.grey.shade600, height: 1.6, fontSize: 14),
                    ),
                    const SizedBox(height: 24),

                    // Quantity Selector
                    const Text('Jumlah', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _quantityButton(Icons.remove, () {
                          if (_quantity > 1) setState(() => _quantity--);
                        }),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            '$_quantity',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        _quantityButton(Icons.add, () {
                          if (_quantity < widget.product.stock) setState(() => _quantity++);
                        }),
                        const SizedBox(width: 16),
                        Text(
                          'Total: ${AppConstants.formatPrice(widget.product.price * _quantity)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textMuted),
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
                                for (int i = 0; i < _quantity; i++) {
                                  if (i == 0) {
                                    context.read<CartProvider>().addToCart(widget.product);
                                  } else {
                                    context.read<CartProvider>().increaseQuantity(widget.product.id);
                                  }
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${widget.product.name} ditambahkan ke keranjang!'),
                                    backgroundColor: AppTheme.success,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    action: SnackBarAction(
                                      label: 'Lihat Keranjang',
                                      textColor: Colors.white,
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const CartScreen()),
                                      ),
                                    ),
                                  ),
                                );
                              }
                            : null,
                        icon: Icon(isInCart ? Icons.shopping_cart : Icons.shopping_cart_outlined),
                        label: Text(widget.product.stock > 0 ? 'Tambah ke Keranjang' : 'Stok Habis'),
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
                                context.read<CartProvider>().addToCart(widget.product);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const CartScreen()),
                                );
                              }
                            : null,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.accent,
                          side: const BorderSide(color: AppTheme.accent),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Beli Sekarang', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 24),
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
