// lib/screens/seller/seller_orders_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/review_provider.dart';
import '../../utils/app_theme.dart';

class SellerOrdersScreen extends StatefulWidget {
  const SellerOrdersScreen({super.key});

  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.currentUser != null) {
        context.read<OrderProvider>().fetchSellerOrders(auth.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Pesanan Masuk')),
      body: orders.isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.errorMessage != null
              ? _buildError(orders.errorMessage!)
              : orders.orders.isEmpty
                  ? _buildEmpty()
                  : RefreshIndicator(
                      onRefresh: () async {
                        final auth = context.read<AuthProvider>();
                        await context
                            .read<OrderProvider>()
                            .fetchSellerOrders(auth.currentUser!.id);
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: orders.orders.length,
                        itemBuilder: (context, i) => _OrderCard(
                          order: orders.orders[i],
                          onRefresh: () {
                            final auth = context.read<AuthProvider>();
                            context
                                .read<OrderProvider>()
                                .fetchSellerOrders(auth.currentUser!.id);
                          },
                        ),
                      ),
                    ),
    );
  }

  Widget _buildEmpty() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'Belum ada pesanan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Pesanan akan muncul di sini',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );

  Widget _buildError(String message) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 56),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final auth = context.read<AuthProvider>();
                context
                    .read<OrderProvider>()
                    .fetchSellerOrders(auth.currentUser!.id);
              },
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
}

// ──────────────────────────────────────────────────────────────
// KARTU PESANAN UNTUK PENJUAL (MENAMPILKAN NAMA PRODUK)
// ──────────────────────────────────────────────────────────────
class _OrderCard extends StatefulWidget {
  final Order order;
  final VoidCallback onRefresh;

  const _OrderCard({required this.order, required this.onRefresh});

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> {
  bool _isUpdating = false;

  static const _statusColors = {
    'pending': AppTheme.warning,
    'confirmed': AppTheme.accent,
    'processing': Color(0xFF6366F1),
    'shipped': Color(0xFF0EA5E9),
    'delivered': AppTheme.success,
    'cancelled': Colors.red,
  };

  static const _nextStatus = {
    'pending': 'confirmed',
    'confirmed': 'processing',
    'processing': 'shipped',
  };

  static const _statusLabels = {
    'pending': 'Konfirmasi Pesanan',
    'confirmed': 'Proses Pesanan',
    'processing': 'Kirim Pesanan',
  };

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isUpdating = true);

    final error = await context
        .read<OrderProvider>()
        .updateOrderStatus(widget.order.id, newStatus);

    setState(() => _isUpdating = false);

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status pesanan berhasil diperbarui ✅'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      widget.onRefresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColors[widget.order.status] ?? Colors.grey;
    final next = _nextStatus[widget.order.status];
    final nextLabel = _statusLabels[widget.order.status] ?? 'Update Status';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Order ID dan Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(Icons.receipt_long, color: statusColor, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Order #${widget.order.id.substring(0, 8).toUpperCase()}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: statusColor,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.order.statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Body: Detail Pesanan
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total Harga
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Pesanan',
                      style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                    Text(
                      AppConstants.formatPrice(widget.order.totalAmount),
                      style: const TextStyle(
                        color: AppTheme.accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // DAFTAR PRODUK YANG DIPESAN
                const Text(
                  'Daftar Produk:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),

                // List produk (jika ada items)
                if (widget.order.items.isNotEmpty)
                  ...widget.order.items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Gambar produk kecil
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item.product.imageUrl,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 40,
                                  height: 40,
                                  color: Colors.grey.shade100,
                                  child: const Icon(Icons.image, size: 20),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Info produk
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${item.quantity} x ${AppConstants.formatPrice(item.product.price)}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Subtotal per item
                            Text(
                              AppConstants.formatPrice(item.totalPrice),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ))
                else
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Data produk tidak tersedia',
                      style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                  ),

                const Divider(height: 24),

                // Informasi Pengiriman
                Row(
                  children: [
                    Icon(Icons.local_shipping_outlined, size: 14, color: AppTheme.textMuted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Kurir: ${widget.order.shippingMethod}',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.payments_outlined, size: 14, color: AppTheme.textMuted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Pembayaran: ${_getPaymentName(widget.order.paymentMethod)}',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on_outlined, size: 14, color: AppTheme.textMuted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.order.shippingAddress,
                        style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (widget.order.note.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.warning.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.note_outlined, size: 14, color: AppTheme.warning),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Catatan: ${widget.order.note}',
                            style: TextStyle(fontSize: 11, color: AppTheme.warning),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Tombol Update Status
                if (next != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _statusColors[next] ?? AppTheme.accent,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _isUpdating ? null : () => _updateStatus(next),
                      child: _isUpdating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              '✓ $nextLabel',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                // Info status shipped
                if (widget.order.status == 'shipped') ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0EA5E9).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF0EA5E9).withOpacity(0.3),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Color(0xFF0EA5E9), size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Menunggu pembeli mengkonfirmasi penerimaan barang',
                            style: TextStyle(color: Color(0xFF0EA5E9), fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getPaymentName(String id) {
    const names = {
      'bca': 'BCA Virtual Account',
      'mandiri': 'Mandiri Virtual Account',
      'bni': 'BNI Virtual Account',
      'bri': 'BRI Virtual Account',
      'gopay': 'GoPay',
      'ovo': 'OVO',
      'dana': 'DANA',
      'shopeepay': 'ShopeePay',
      'cod': 'Cash on Delivery',
      'credit': 'Kartu Kredit/Debit',
    };
    return names[id] ?? id;
  }
}