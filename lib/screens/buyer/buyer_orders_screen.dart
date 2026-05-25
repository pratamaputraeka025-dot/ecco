// lib/screens/buyer/buyer_orders_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/review_provider.dart';
import '../../utils/app_theme.dart';
import '../product/review_screen.dart';

// ══════════════════════════════════════════════════════════════════
// HALAMAN DAFTAR PESANAN PEMBELI
// ══════════════════════════════════════════════════════════════════
class BuyerOrdersScreen extends StatefulWidget {
  const BuyerOrdersScreen({super.key});

  @override
  State<BuyerOrdersScreen> createState() => _BuyerOrdersScreenState();
}

class _BuyerOrdersScreenState extends State<BuyerOrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  Future<void> _refresh() async {
    final auth = context.read<AuthProvider>();
    if (auth.currentUser != null) {
      await context.read<OrderProvider>().fetchMyOrders(auth.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Pesanan Saya')),
      body: orders.isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.errorMessage != null
              ? _buildError(orders.errorMessage!)
              : orders.orders.isEmpty
                  ? _buildEmpty()
                  : RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: orders.orders.length,
                        itemBuilder: (context, i) => _OrderCard(
                          order: orders.orders[i],
                          onRefresh: _refresh,
                        ),
                      ),
                    ),
    );
  }

  Widget _buildEmpty() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.receipt_long_outlined, size: 100, color: Colors.grey.shade300),
      const SizedBox(height: 20),
      const Text('Belum Ada Pesanan',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text('Yuk, mulai belanja sekarang!',
          style: TextStyle(color: Colors.grey.shade500)),
      const SizedBox(height: 24),
      ElevatedButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Mulai Belanja'),
      ),
    ]),
  );

  Widget _buildError(String message) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.error_outline, color: Colors.red, size: 56),
      const SizedBox(height: 12),
      Text(message,
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center),
    ]),
  );
}

// ══════════════════════════════════════════════════════════════════
// KARTU SATU PESANAN (di daftar)
// ══════════════════════════════════════════════════════════════════
class _OrderCard extends StatefulWidget {
  final Order order;
  final VoidCallback onRefresh;

  const _OrderCard({required this.order, required this.onRefresh});

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> {
  bool _isReviewing = false;

  static const _statusColors = {
    'pending': Color(0xFFF59E0B),
    'confirmed': Color(0xFFE94560),
    'processing': Color(0xFF6366F1),
    'shipped': Color(0xFF0EA5E9),
    'delivered': Color(0xFF10B981),
    'cancelled': Colors.red,
  };

  static const _statusIcons = {
    'pending': Icons.hourglass_empty_rounded,
    'confirmed': Icons.check_circle_outline,
    'processing': Icons.inventory_2_outlined,
    'shipped': Icons.local_shipping_outlined,
    'delivered': Icons.done_all_rounded,
    'cancelled': Icons.cancel_outlined,
  };

  Future<void> _checkAndNavigateToReview() async {
    if (widget.order.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada produk dalam pesanan ini'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isReviewing = true);

    final reviewProvider = context.read<ReviewProvider>();
    final product = widget.order.items.first.product;
    final canReview = await reviewProvider.canReview(widget.order.id, product.id);

    setState(() => _isReviewing = false);

    if (!canReview) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda sudah memberikan review untuk pesanan ini'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Navigasi ke halaman review
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewScreen(
          product: product,
          orderId: widget.order.id,
        ),
      ),
    );

    if (result == true) {
      widget.onRefresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColors[widget.order.status] ?? Colors.grey;
    final icon = _statusIcons[widget.order.status] ?? Icons.help_outline;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => OrderDetailScreen(order: widget.order)),
      ).then((_) => widget.onRefresh()),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Column(
          children: [
            // Header status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Icon(icon, color: color, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    widget.order.statusLabel,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(widget.order.createdAt),
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                  ),
                ],
              ),
            ),
            // Body
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.tag, size: 14, color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        'Order #${widget.order.id.substring(0, 8).toUpperCase()}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppConstants.formatPrice(widget.order.totalAmount),
                        style: const TextStyle(
                          color: AppTheme.accent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      _paymentBadge(widget.order.paymentMethod),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.local_shipping_outlined, size: 14, color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        widget.order.shippingMethod,
                        style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.order.shippingAddress,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // TOMBOL REVIEW (hanya untuk status delivered)
                  if (widget.order.status == 'delivered') ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isReviewing ? null : _checkAndNavigateToReview,
                        icon: _isReviewing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.star_border, size: 18),
                        label: Text(
                          _isReviewing ? 'Memeriksa...' : 'Beri Review & Rating',
                          style: const TextStyle(fontSize: 13),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.accent,
                          side: const BorderSide(color: AppTheme.accent),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Link lihat detail
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Lihat Detail',
                        style: TextStyle(
                          color: AppTheme.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_ios, size: 12, color: AppTheme.accent),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentBadge(String method) {
    const names = {
      'bca': 'BCA VA',
      'mandiri': 'Mandiri VA',
      'bni': 'BNI VA',
      'bri': 'BRI VA',
      'gopay': 'GoPay',
      'ovo': 'OVO',
      'dana': 'DANA',
      'shopeepay': 'ShopeePay',
      'cod': 'COD',
      'credit': 'Kartu Kredit',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        names[method] ?? method,
        style: const TextStyle(
          fontSize: 11,
          color: AppTheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}

// ══════════════════════════════════════════════════════════════════
// HALAMAN DETAIL PESANAN
// ══════════════════════════════════════════════════════════════════
class OrderDetailScreen extends StatefulWidget {
  final Order order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late Order _order;

  static const _statusColors = {
    'pending': Color(0xFFF59E0B),
    'confirmed': Color(0xFFE94560),
    'processing': Color(0xFF6366F1),
    'shipped': Color(0xFF0EA5E9),
    'delivered': Color(0xFF10B981),
    'cancelled': Colors.red,
  };

  static const _statusFlow = [
    'pending', 'confirmed', 'processing', 'shipped', 'delivered'
  ];

  static const _statusInfo = {
    'pending': ('Menunggu Konfirmasi', 'Pesanan berhasil dibuat, menunggu konfirmasi penjual'),
    'confirmed': ('Dikonfirmasi', 'Penjual sudah mengkonfirmasi pesananmu'),
    'processing': ('Diproses', 'Penjual sedang menyiapkan barangmu'),
    'shipped': ('Dalam Pengiriman', 'Paketmu sedang dalam perjalanan'),
    'delivered': ('Selesai', 'Paket sudah tiba di tujuan 🎉'),
    'cancelled': ('Dibatalkan', 'Pesanan ini telah dibatalkan'),
  };

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  void _onOrderDelivered() {
    if (!mounted) return;
    setState(() {
      _order = Order(
        id: _order.id,
        buyerId: _order.buyerId,
        items: _order.items,
        totalAmount: _order.totalAmount,
        status: 'delivered',
        createdAt: _order.createdAt,
        paymentMethod: _order.paymentMethod,
        shippingAddress: _order.shippingAddress,
        shippingMethod: _order.shippingMethod,
        note: _order.note,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColors[_order.status] ?? Colors.grey;
    final isCancelled = _order.status == 'cancelled';
    final currentIdx = _statusFlow.indexOf(_order.status);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(title: const Text('Detail Pesanan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status utama
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_getStatusIcon(_order.status), color: statusColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _statusInfo[_order.status]?.$1 ?? _order.status,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _statusInfo[_order.status]?.$2 ?? '',
                          style: TextStyle(
                            color: statusColor.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Progress timeline
            if (!isCancelled) _buildTimeline(currentIdx),
            if (!isCancelled) const SizedBox(height: 16),

            // Info pesanan
            _sectionCard(
              title: 'Informasi Pesanan',
              icon: Icons.receipt_outlined,
              child: Column(
                children: [
                  _infoRow('No. Pesanan', '#${_order.id.substring(0, 8).toUpperCase()}'),
                  _infoRow('Tanggal', _formatDateFull(_order.createdAt)),
                  _infoRow('Status', _order.statusLabel, valueColor: statusColor),
                  _infoRow('Metode Bayar', _getPaymentName(_order.paymentMethod)),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Info pengiriman
            _sectionCard(
              title: 'Pengiriman',
              icon: Icons.local_shipping_outlined,
              child: Column(
                children: [
                  _infoRow('Kurir', _order.shippingMethod),
                  _infoRow('Alamat', _order.shippingAddress, multiLine: true),
                  if (_order.note.isNotEmpty)
                    _infoRow('Catatan', _order.note, multiLine: true),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Ringkasan pembayaran
            _sectionCard(
              title: 'Ringkasan Pembayaran',
              icon: Icons.payments_outlined,
              child: Column(
                children: [
                  _infoRow(
                    'Total Pesanan',
                    AppConstants.formatPrice(_order.totalAmount),
                    valueColor: AppTheme.accent,
                    valueBold: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Banner shipped + tombol konfirmasi
            if (_order.status == 'shipped') ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0EA5E9).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF0EA5E9).withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.local_shipping_outlined, color: Color(0xFF0EA5E9), size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Paketmu sedang dalam perjalanan. Estimasi tiba 1-5 hari kerja.',
                        style: TextStyle(color: Color(0xFF0EA5E9), fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _ConfirmReceivedButton(
                orderId: _order.id,
                onConfirmed: _onOrderDelivered,
              ),
            ],

            // Banner selesai
            if (_order.status == 'delivered')
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.success.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified_outlined, color: AppTheme.success, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Pesanan telah sampai. Terima kasih sudah belanja! 🎉',
                        style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(int currentIdx) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.timeline, color: AppTheme.accent, size: 18),
              SizedBox(width: 8),
              Text('Progress Pesanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 16),
          ..._statusFlow.asMap().entries.map((entry) {
            final idx = entry.key;
            final status = entry.value;
            final isDone = idx <= currentIdx;
            final isNow = idx == currentIdx;
            final isLast = idx == _statusFlow.length - 1;
            final color = isDone
                ? (_statusColors[status] ?? AppTheme.success)
                : Colors.grey.shade300;
            final info = _statusInfo[status];

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isDone ? color : Colors.grey.shade200,
                        shape: BoxShape.circle,
                        border: isNow ? Border.all(color: color, width: 3) : null,
                        boxShadow: isNow
                            ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8)]
                            : [],
                      ),
                      child: Icon(
                        isDone ? Icons.check_rounded : Icons.circle,
                        color: isDone ? Colors.white : Colors.grey.shade400,
                        size: isDone ? 16 : 8,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 36,
                        color: idx < currentIdx ? color : Colors.grey.shade200,
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 20, top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          info?.$1 ?? status,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isDone ? AppTheme.textDark : Colors.grey.shade400,
                          ),
                        ),
                        if (isNow) ...[
                          const SizedBox(height: 3),
                          Text(
                            info?.$2 ?? '',
                            style: TextStyle(fontSize: 11, color: color),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.accent, size: 18),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const Divider(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {
    Color? valueColor,
    bool valueBold = false,
    bool multiLine = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: multiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: valueBold ? FontWeight.bold : FontWeight.w500,
                color: valueColor ?? AppTheme.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    const icons = {
      'pending': Icons.hourglass_empty_rounded,
      'confirmed': Icons.check_circle_outline,
      'processing': Icons.inventory_2_outlined,
      'shipped': Icons.local_shipping_outlined,
      'delivered': Icons.done_all_rounded,
      'cancelled': Icons.cancel_outlined,
    };
    return icons[status] ?? Icons.help_outline;
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

  String _formatDateFull(DateTime dt) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ══════════════════════════════════════════════════════════════════
// TOMBOL KONFIRMASI PENERIMAAN BARANG
// ══════════════════════════════════════════════════════════════════
class _ConfirmReceivedButton extends StatefulWidget {
  final String orderId;
  final VoidCallback onConfirmed;

  const _ConfirmReceivedButton({
    required this.orderId,
    required this.onConfirmed,
  });

  @override
  State<_ConfirmReceivedButton> createState() => _ConfirmReceivedButtonState();
}

class _ConfirmReceivedButtonState extends State<_ConfirmReceivedButton> {
  bool _isLoading = false;

  Future<void> _confirm() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Penerimaan'),
        content: const Text(
          'Apakah barang sudah kamu terima dengan kondisi baik?\n\n'
          'Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Belum'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
            child: const Text('Ya, Sudah Diterima'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLoading = true);

    final err = await context
        .read<OrderProvider>()
        .updateOrderStatus(widget.orderId, 'delivered');

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: Colors.red),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terima kasih! Pesanan dikonfirmasi selesai ✅'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      widget.onConfirmed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _confirm,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.success,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: _isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.check_circle_outline, color: Colors.white),
        label: Text(
          _isLoading ? 'Mengkonfirmasi...' : 'Konfirmasi Barang Diterima',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}