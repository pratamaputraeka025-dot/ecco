// lib/screens/checkout/payment_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/providers.dart';
import '../../utils/app_theme.dart';
import 'order_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String shippingAddress;
  final String shippingMethod;
  final String note;

  const PaymentScreen({
    super.key,
    required this.shippingAddress,
    required this.shippingMethod,
    required this.note,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPayment = '';
  bool _isProcessing = false;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'category': 'Transfer Bank',
      'methods': [
        {'id': 'bca', 'name': 'BCA Virtual Account', 'icon': Icons.account_balance, 'color': Color(0xFF003DA5)},
        {'id': 'mandiri', 'name': 'Mandiri Virtual Account', 'icon': Icons.account_balance, 'color': Color(0xFF003087)},
        {'id': 'bni', 'name': 'BNI Virtual Account', 'icon': Icons.account_balance, 'color': Color(0xFFFF6200)},
        {'id': 'bri', 'name': 'BRI Virtual Account', 'icon': Icons.account_balance, 'color': Color(0xFF00529B)},
      ],
    },
    {
      'category': 'Dompet Digital',
      'methods': [
        {'id': 'gopay', 'name': 'GoPay', 'icon': Icons.account_balance_wallet, 'color': Color(0xFF00AED6)},
        {'id': 'ovo', 'name': 'OVO', 'icon': Icons.account_balance_wallet, 'color': Color(0xFF4C3494)},
        {'id': 'dana', 'name': 'DANA', 'icon': Icons.account_balance_wallet, 'color': Color(0xFF108ED4)},
        {'id': 'shopeepay', 'name': 'ShopeePay', 'icon': Icons.account_balance_wallet, 'color': Color(0xFFEE4D2D)},
      ],
    },
    {
      'category': 'Bayar di Tempat',
      'methods': [
        {'id': 'cod', 'name': 'Cash on Delivery (COD)', 'icon': Icons.local_shipping, 'color': AppTheme.success},
      ],
    },
    {
      'category': 'Kartu',
      'methods': [
        {'id': 'credit', 'name': 'Kartu Kredit / Debit', 'icon': Icons.credit_card, 'color': Color(0xFF1A1A2E)},
      ],
    },
  ];

  Future<void> _processPayment() async {
    if (_selectedPayment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Pilih metode pembayaran terlebih dahulu'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    final cart = context.read<CartProvider>();
    final orderId = 'ORD${DateTime.now().millisecondsSinceEpoch}';

    setState(() => _isProcessing = false);

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => OrderSuccessScreen(
            orderId: orderId,
            totalAmount: cart.grandTotal,
            paymentMethod: _selectedPayment,
            shippingAddress: widget.shippingAddress,
          ),
        ),
        (route) => route.isFirst,
      );
      cart.clearCart();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Metode Pembayaran')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Amount to pay
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.secondary],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Pembayaran', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 8),
                      Text(
                        AppConstants.formatPrice(cart.grandTotal),
                        style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Via ${widget.shippingMethod} | ${cart.itemCount} item',
                        style: const TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                ..._paymentMethods.map((category) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10, top: 4),
                      child: Text(
                        category['category'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textMuted),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                      ),
                      child: Column(
                        children: (category['methods'] as List).map<Widget>((method) {
                          final isSelected = _selectedPayment == method['id'];
                          return InkWell(
                            onTap: () => setState(() => _selectedPayment = method['id']),
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: (method['color'] as Color).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(method['icon'], color: method['color'], size: 22),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(method['name'],
                                        style: TextStyle(
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                          color: isSelected ? AppTheme.accent : AppTheme.textDark,
                                        )),
                                  ),
                                  Radio<String>(
                                    value: method['id'],
                                    groupValue: _selectedPayment,
                                    onChanged: (val) => setState(() => _selectedPayment = val!),
                                    activeColor: AppTheme.accent,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                )),

                const SizedBox(height: 8),

                // Security note
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.success.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.security, color: AppTheme.success, size: 18),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Pembayaran dijamin aman dan terenkripsi',
                          style: TextStyle(color: AppTheme.success, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 80), // space for button
              ],
            ),
          ),

          // Bottom button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processPayment,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: _isProcessing
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text('Memproses Pembayaran...'),
                          ],
                        )
                      : const Text('Bayar Sekarang 🔒', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
