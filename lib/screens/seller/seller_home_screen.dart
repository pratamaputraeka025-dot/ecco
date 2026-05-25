// lib/screens/seller/seller_home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';
import '../../utils/app_theme.dart';
import 'add_product_screen.dart';
import 'edit_product_screen.dart';
import 'seller_orders_screen.dart';

class SellerHomeScreen extends StatefulWidget {
  const SellerHomeScreen({super.key});

  @override
  State<SellerHomeScreen> createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.currentUser != null) {
        final productProvider = context.read<ProductProvider>();
        final orderProvider = context.read<OrderProvider>();
        
        productProvider.fetchMyProducts(auth.currentUser!.id);
        orderProvider.fetchSellerOrders(auth.currentUser!.id);
      }
    });
  }

  Future<void> _refreshData() async {
    final auth = context.read<AuthProvider>();
    if (auth.currentUser != null) {
      await Future.wait([
        context.read<ProductProvider>().fetchMyProducts(auth.currentUser!.id),
        context.read<OrderProvider>().fetchSellerOrders(auth.currentUser!.id),
      ]);
      
      // Tampilkan snackbar jika ada notifikasi baru
      final orderProvider = context.read<OrderProvider>();
      if (orderProvider.unreadNotifications > 0 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.notifications_active, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${orderProvider.unreadNotifications} pesanan baru!',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.accent,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'LIHAT',
              textColor: Colors.white,
              onPressed: () {
                orderProvider.markAllNotificationsAsRead();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SellerOrdersScreen()),
                );
              },
            ),
          ),
        );
      }
    }
  }

  void _showNotificationsDialog(BuildContext context) {
    final orderProvider = context.read<OrderProvider>();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.notifications, color: AppTheme.accent),
            const SizedBox(width: 8),
            const Text('Notifikasi'),
            const Spacer(),
            TextButton(
              onPressed: () {
                orderProvider.clearNotifications();
                Navigator.pop(ctx);
              },
              child: const Text('Bersihkan'),
            ),
          ],
        ),
        content: orderProvider.notifications.isEmpty
            ? SizedBox(
                height: 100,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none, size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 8),
                      Text(
                        'Tidak ada notifikasi',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
              )
            : SizedBox(
                width: double.maxFinite,
                height: 300,
                child: ListView.builder(
                  itemCount: orderProvider.notifications.length,
                  itemBuilder: (ctx, index) {
                    final notif = orderProvider.notifications[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: notif['isRead'] 
                            ? Colors.grey.shade200 
                            : AppTheme.accent.withOpacity(0.2),
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          color: notif['isRead'] ? Colors.grey : AppTheme.accent,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        notif['title'],
                        style: TextStyle(
                          fontWeight: notif['isRead'] ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(notif['body']),
                      trailing: Text(
                        _formatTime(notif['timestamp']),
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                      ),
                      onTap: () {
                        orderProvider.markNotificationAsRead(index);
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SellerOrdersScreen(),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final products = context.watch<ProductProvider>();
    final orderProvider = context.watch<OrderProvider>();

    if (auth.currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              auth.currentUser?.name ?? 'Toko Saya',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Dashboard Penjual',
              style: TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          // Tombol Notifikasi dengan Badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                tooltip: 'Notifikasi',
                onPressed: () {
                  orderProvider.markAllNotificationsAsRead();
                  _showNotificationsDialog(context);
                },
              ),
              if (orderProvider.unreadNotifications > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${orderProvider.unreadNotifications}',
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
          // Tombol Pesanan
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            tooltip: 'Pesanan Masuk',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SellerOrdersScreen()),
            ),
          ),
          // Tombol Refresh
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _refreshData,
          ),
          // Tombol Logout
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Keluar',
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: products.isLoading
            ? const Center(child: CircularProgressIndicator())
            : products.errorMessage != null
                ? _buildError(products.errorMessage!)
                : products.products.isEmpty
                    ? _buildEmpty()
                    : Column(
                        children: [
                          // Stat bar ringkas
                          if (products.products.isNotEmpty)
                            _buildStatBar(products),
                          Expanded(
                            child: _buildProductList(products, auth),
                          ),
                        ],
                      ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddProductScreen()),
        ).then((_) => _loadData()),
        backgroundColor: AppTheme.accent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah Produk', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildStatBar(ProductProvider products) {
    final totalStok = products.products.fold(0, (s, p) => s + p.stock);
    final stokHabis = products.products.where((p) => p.stock == 0).length;
    final totalProduk = products.products.length;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          _statItem('Produk', '$totalProduk', AppTheme.accent),
          Container(width: 1, height: 36, color: Colors.grey.shade200),
          _statItem('Total Stok', '$totalStok', AppTheme.success),
          Container(width: 1, height: 36, color: Colors.grey.shade200),
          _statItem('Stok Habis', '$stokHabis', stokHabis > 0 ? Colors.red : Colors.grey),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) => Expanded(
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
            Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          ],
        ),
      );

  Widget _buildEmpty() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store_mall_directory_outlined, size: 100, color: Colors.grey.shade300),
            const SizedBox(height: 20),
            const Text('Belum Ada Produk', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Tap tombol + untuk tambah produk pertamamu!',
                style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      );

  Widget _buildError(String message) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 56),
            const SizedBox(height: 12),
            Text(message, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: const Text('Coba Lagi')),
          ],
        ),
      );

  Widget _buildProductList(ProductProvider products, AuthProvider auth) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: products.products.length,
      itemBuilder: (context, index) {
        final product = products.products[index];
        return _ProductCard(
          product: product,
          onEdit: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EditProductScreen(product: product)),
          ).then((changed) {
            if (changed == true) _loadData();
          }),
          onDelete: () => _confirmDelete(context, product.id, product.name),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, String productId, String productName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Produk'),
        content: Text('Apakah Anda yakin ingin menghapus produk "$productName"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final error = await context.read<ProductProvider>().deleteProduct(productId);
    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produk "$productName" berhasil dihapus ✅'), backgroundColor: AppTheme.success),
      );
      _loadData();
    }
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar'),
        content: const Text('Yakin ingin keluar dari akun penjual?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthProvider>().logout();
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// KARTU PRODUK PENJUAL
// ──────────────────────────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isLowStock = product.stock > 0 && product.stock <= 5;
    final isOutStock = product.stock == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        border: isOutStock
            ? Border.all(color: Colors.red.shade200, width: 1.5)
            : isLowStock
                ? Border.all(color: AppTheme.warning.withOpacity(0.4), width: 1.5)
                : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Gambar produk
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                product.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey.shade100,
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Info produk
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppConstants.formatPrice(product.price),
                    style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _badge(
                        isOutStock ? 'Stok Habis' : isLowStock ? 'Sisa ${product.stock}' : 'Stok: ${product.stock}',
                        isOutStock ? Colors.red : isLowStock ? AppTheme.warning : AppTheme.success,
                      ),
                      const SizedBox(width: 6),
                      _badge(product.category, AppTheme.primary),
                    ],
                  ),
                ],
              ),
            ),

            // Tombol aksi
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Tooltip(
                  message: 'Edit produk',
                  child: InkWell(
                    onTap: onEdit,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.edit_outlined, color: AppTheme.accent, size: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Tooltip(
                  message: 'Hapus produk',
                  child: InkWell(
                    onTap: onDelete,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
        ),
      );
}