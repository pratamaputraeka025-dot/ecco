// lib/screens/checkout/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/providers.dart';
import '../../utils/app_theme.dart';
import 'payment_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();
  String _selectedShipping = 'JNE Regular';
  final List<String> _shippingOptions = ['JNE Regular', 'JNE Express', 'SiCepat', 'Anteraja'];

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _addressController.text = user?.address ?? '';
  }

  @override
  void dispose() {
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Delivery Address
            _sectionCard(
              icon: Icons.location_on_outlined,
              title: 'Alamat Pengiriman',
              child: Column(
                children: [
                  TextField(
                    controller: _addressController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Masukkan alamat lengkap...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 16, color: AppTheme.textMuted),
                      const SizedBox(width: 6),
                      Text(auth.currentUser?.name ?? '', style: const TextStyle(fontSize: 13)),
                      const SizedBox(width: 16),
                      const Icon(Icons.phone_outlined, size: 16, color: AppTheme.textMuted),
                      const SizedBox(width: 6),
                      Text(auth.currentUser?.phone ?? '', style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Order Items
            _sectionCard(
              icon: Icons.shopping_bag_outlined,
              title: 'Daftar Pesanan (${cart.itemCount} item)',
              child: Column(
                children: cart.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.product.imageUrl,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 56, height: 56, color: Colors.grey.shade100,
                            child: const Icon(Icons.image, size: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.product.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            Text('${item.quantity}x ${AppConstants.formatPrice(item.product.price)}',
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                          ],
                        ),
                      ),
                      Text(AppConstants.formatPrice(item.totalPrice),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                )).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Shipping
            _sectionCard(
              icon: Icons.local_shipping_outlined,
              title: 'Metode Pengiriman',
              child: Column(
                children: _shippingOptions.map((option) => RadioListTile(
                  value: option,
                  groupValue: _selectedShipping,
                  onChanged: (val) => setState(() => _selectedShipping = val!),
                  title: Text(option, style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text(option.contains('Express') ? 'Estimasi 1-2 hari' : 'Estimasi 3-5 hari',
                      style: const TextStyle(fontSize: 12)),
                  secondary: Text(
                    cart.shippingCost == 0 ? 'GRATIS' : AppConstants.formatPrice(cart.shippingCost),
                    style: TextStyle(
                      color: cart.shippingCost == 0 ? AppTheme.success : AppTheme.textDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  activeColor: AppTheme.accent,
                  contentPadding: EdgeInsets.zero,
                )).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Notes
            _sectionCard(
              icon: Icons.note_outlined,
              title: 'Catatan (Opsional)',
              child: TextField(
                controller: _noteController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Tambah catatan untuk penjual...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ringkasan Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  _row('Subtotal Produk', AppConstants.formatPrice(cart.totalAmount)),
                  const SizedBox(height: 8),
                  _row('Ongkos Kirim ($_selectedShipping)',
                      cart.shippingCost == 0 ? 'GRATIS 🎉' : AppConstants.formatPrice(cart.shippingCost),
                      valueColor: cart.shippingCost == 0 ? AppTheme.success : null),
                  const Divider(height: 20),
                  _row('Total Pembayaran', AppConstants.formatPrice(cart.grandTotal),
                      isBold: true, fontSize: 16, valueColor: AppTheme.accent),
                ],
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addressController.text.isEmpty
                    ? null
                    : () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaymentScreen(
                            shippingAddress: _addressController.text,
                            shippingMethod: _selectedShipping,
                            note: _noteController.text,
                          ),
                        ),
                      ),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Pilih Metode Pembayaran →', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({required IconData icon, required String title, required Widget child}) {
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
              Icon(icon, color: AppTheme.accent, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool isBold = false, double fontSize = 14, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: fontSize, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(fontSize: fontSize, fontWeight: isBold ? FontWeight.bold : FontWeight.w600, color: valueColor)),
      ],
    );
  }
}
