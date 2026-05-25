// lib/screens/checkout/order_success_screen.dart
import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../buyer/buyer_orders_screen.dart';

class OrderSuccessScreen extends StatefulWidget {
  final String orderId;
  final double totalAmount;
  final String paymentMethod;
  final String shippingAddress;

  const OrderSuccessScreen({
    super.key,
    required this.orderId,
    required this.totalAmount,
    required this.paymentMethod,
    required this.shippingAddress,
  });

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0)),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getPaymentMethodName(String id) {
    const names = {
      'bca':      'BCA Virtual Account',
      'mandiri':  'Mandiri Virtual Account',
      'bni':      'BNI Virtual Account',
      'bri':      'BRI Virtual Account',
      'gopay':    'GoPay',
      'ovo':      'OVO',
      'dana':     'DANA',
      'shopeepay':'ShopeePay',
      'cod':      'Cash on Delivery',
      'credit':   'Kartu Kredit/Debit',
    };
    return names[id] ?? id;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // ── Animasi centang ──────────────────────────
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(
                      color: AppTheme.success,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.success.withOpacity(0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.check_rounded,
                        color: Colors.white, size: 64),
                  ),
                ),
                const SizedBox(height: 24),

                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      const Text(
                        'Pesanan Berhasil! 🎉',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Terima kasih sudah belanja di ShopNow!\nPesananmu sedang diproses.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                            height: 1.5),
                      ),
                      const SizedBox(height: 32),

                      // ── Detail pesanan ───────────────────────
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 20),
                          ],
                        ),
                        child: Column(children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('No. Pesanan',
                                  style: TextStyle(
                                      color: AppTheme.textMuted, fontSize: 13)),
                              Text(
                                widget.orderId.length >= 16
                                    ? widget.orderId.substring(0, 16)
                                    : widget.orderId,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 12),
                          _detailRow('Total Bayar',
                              AppConstants.formatPrice(widget.totalAmount),
                              isAmount: true),
                          const SizedBox(height: 10),
                          _detailRow('Metode Bayar',
                              _getPaymentMethodName(widget.paymentMethod)),
                          const SizedBox(height: 10),
                          _detailRow('Status', 'Menunggu Konfirmasi',
                              statusColor: AppTheme.warning),
                          const SizedBox(height: 10),
                          _detailRow('Estimasi Tiba', '3-5 Hari Kerja'),
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Kirim ke',
                                  style: TextStyle(
                                      color: AppTheme.textMuted, fontSize: 13)),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  widget.shippingAddress,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ]),
                      ),

                      const SizedBox(height: 24),

                      // ── Progress steps ───────────────────────
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 20),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Status Pesanan',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(height: 16),
                            _statusStep('Pesanan Dibuat',
                                'Pesananmu berhasil dibuat', true, true),
                            _statusStep('Pembayaran Dikonfirmasi',
                                'Menunggu konfirmasi pembayaran', true, false),
                            _statusStep('Diproses Penjual',
                                'Pesanan sedang disiapkan', false, false),
                            _statusStep('Dalam Pengiriman',
                                'Pesanan dalam perjalanan', false, false),
                            _statusStep('Pesanan Tiba',
                                'Barang sampai di tujuan', false, false,
                                isLast: true),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ── Tombol Kembali ke Beranda ────────────
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.popUntil(
                              context, (route) => route.isFirst),
                          style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16)),
                          child: const Text('Kembali ke Beranda',
                              style: TextStyle(fontSize: 16)),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── Tombol Lacak Pesanan (sekarang berfungsi!) ──
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Kembali ke home dulu, lalu buka BuyerOrdersScreen
                            Navigator.popUntil(
                                context, (route) => route.isFirst);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const BuyerOrdersScreen()),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.accent,
                            side: const BorderSide(color: AppTheme.accent),
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.receipt_long_outlined,
                              size: 18),
                          label: const Text('Lacak Pesanan',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value,
      {bool isAmount = false, Color? statusColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style:
                const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isAmount ? 15 : 13,
            color: statusColor ??
                (isAmount ? AppTheme.accent : AppTheme.textDark),
          ),
        ),
      ],
    );
  }

  Widget _statusStep(String title, String subtitle, bool isDone, bool isActive,
      {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(children: [
          Container(
            width: 24, height: 24,
            decoration: BoxDecoration(
              color: isDone
                  ? AppTheme.success
                  : (isActive ? AppTheme.accent : Colors.grey.shade200),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDone ? Icons.check : Icons.circle,
              color: Colors.white,
              size: isDone ? 14 : 8,
            ),
          ),
          if (!isLast)
            Container(
                width: 2,
                height: 30,
                color: isDone ? AppTheme.success : Colors.grey.shade200),
        ]),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: isDone || isActive
                          ? AppTheme.textDark
                          : Colors.grey.shade400,
                    )),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade400)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}