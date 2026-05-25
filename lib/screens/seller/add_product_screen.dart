// lib/screens/seller/add_product_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../utils/app_theme.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();
  String _selectedCategory = 'Sepeda Gunung (MTB)';
  bool _isSubmitting = false;

  // KATEGORI SEPEDA - SAMA DENGAN YANG DI PRODUCT_PROVIDER
  final List<String> _categories = [
    'Sepeda Gunung (MTB)',
    'Sepeda Road Bike',
    'Sepeda Lipat',
    'Sepeda City/Urban',
    'Sepeda Anak',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final auth = context.read<AuthProvider>();
    final product = Product(
      id: '',
      sellerId: auth.currentUser!.id,
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      price: double.parse(_priceCtrl.text.replaceAll('.', '').replaceAll(',', '')),
      imageUrl: _imageCtrl.text.trim(),
      category: _selectedCategory,
      stock: int.parse(_stockCtrl.text),
      rating: 0,
    );

    final error = await context.read<ProductProvider>().addProduct(product);

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produk berhasil ditambahkan! ✅'),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Produk')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nama Produk
              _label('Nama Produk'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  hintText: 'Contoh: Sepeda Gunung Polygon Siskiu T7',
                  prefixIcon: Icon(Icons.bike_scooter),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Nama produk wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // Deskripsi
              _label('Deskripsi'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Deskripsikan produk sepeda anda...',
                ),
                validator: (v) => v == null || v.isEmpty ? 'Deskripsi wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // Harga & Stok dalam satu Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Harga (Rp)'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _priceCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: '100000',
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Wajib diisi';
                            final clean = v.replaceAll('.', '').replaceAll(',', '');
                            if (double.tryParse(clean) == null) return 'Angka tidak valid';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Stok'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _stockCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: '10',
                            prefixIcon: Icon(Icons.warehouse),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Wajib diisi';
                            if (int.tryParse(v) == null) return 'Angka tidak valid';
                            if (int.parse(v) < 0) return 'Stok minimal 0';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Kategori (Dropdown dengan tema sepeda)
              _label('Kategori'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((c) {
                  return DropdownMenuItem<String>(
                    value: c,
                    child: Row(
                      children: [
                        Icon(_getCategoryIcon(c), size: 18, color: AppTheme.accent),
                        const SizedBox(width: 8),
                        Text(c),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedCategory = v!),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kategori wajib dipilih';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // URL Gambar
              _label('URL Gambar'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _imageCtrl,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  hintText: 'https://images.unsplash.com/...',
                  helperText: 'Pakai link dari Unsplash atau hosting gambar lain',
                  prefixIcon: Icon(Icons.image_outlined),
                ),
                validator: (v) => v == null || v.isEmpty ? 'URL gambar wajib diisi' : null,
              ),

              // Preview gambar
              if (_imageCtrl.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _imageCtrl.text,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 80,
                        color: Colors.grey.shade100,
                        child: const Center(
                          child: Text('URL gambar tidak valid'),
                        ),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 32),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Simpan Produk', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      );

  IconData _getCategoryIcon(String category) {
    if (category.contains('Sepeda Gunung')) return Icons.terrain;
    if (category.contains('Road Bike')) return Icons.speed;
    if (category.contains('Sepeda Lipat')) return Icons.folder;
    if (category.contains('City')) return Icons.location_city;
    if (category.contains('Anak')) return Icons.child_care;
    if (category.contains('Helm')) return Icons.security;
    if (category.contains('Aksesoris')) return Icons.shopping_bag;
    if (category.contains('Komponen')) return Icons.build;
    if (category.contains('Perlengkapan')) return Icons.backpack;
    return Icons.bike_scooter;
  }
}