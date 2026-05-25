// lib/screens/seller/edit_product_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../utils/app_theme.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _stockCtrl;
  late final TextEditingController _imageCtrl;
  late String _selectedCategory;
  bool _isSubmitting = false;

  // PASTIKAN KATEGORI SAMA DENGAN YANG DI PRODUCT_PROVIDER
  final List<String> _categories = [
    'Sepeda Gunung (MTB)',
    'Sepeda Road Bike',
    'Sepeda Lipat',
    'Sepeda City/Urban',
    'Sepeda Anak',
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.product.name);
    _descCtrl = TextEditingController(text: widget.product.description);
    _priceCtrl = TextEditingController(text: widget.product.price.toStringAsFixed(0));
    _stockCtrl = TextEditingController(text: widget.product.stock.toString());
    _imageCtrl = TextEditingController(text: widget.product.imageUrl);
    _selectedCategory = widget.product.category;
    
    // DEBUG: Cek apakah kategori ada di list
    print('Kategori produk: ${widget.product.category}');
    print('Ada di list: ${_categories.contains(widget.product.category)}');
  }

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

    final updates = <String, dynamic>{
      'name': _nameCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'price': double.parse(_priceCtrl.text.replaceAll(',', '').replaceAll('.', '')),
      'stock': int.parse(_stockCtrl.text.trim()),
      'image_url': _imageCtrl.text.trim(),
      'category': _selectedCategory,
    };

    final error = await context.read<ProductProvider>().updateProduct(
      widget.product.id,
      updates,
    );

    setState(() => _isSubmitting = false);
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
        const SnackBar(
          content: Text('Produk berhasil diperbarui! ✅'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Produk'),
        actions: [
          TextButton.icon(
            onPressed: _isSubmitting ? null : _submit,
            icon: _isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined, color: Colors.white),
            label: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_imageCtrl.text.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    _imageCtrl.text,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 120,
                      color: Colors.grey.shade100,
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              _label('URL Gambar'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _imageCtrl,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  hintText: 'https://images.unsplash.com/...',
                  prefixIcon: Icon(Icons.image_outlined),
                ),
                onChanged: (_) => setState(() {}),
                validator: (v) => v == null || v.isEmpty ? 'URL gambar wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              _label('Nama Produk'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  hintText: 'Nama produk',
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Nama produk wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              _label('Deskripsi'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Deskripsi produk...',
                ),
                validator: (v) => v == null || v.isEmpty ? 'Deskripsi wajib diisi' : null,
              ),
              const SizedBox(height: 16),

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
                            prefixIcon: Icon(Icons.warehouse_outlined),
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

              _label('Kategori'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _categories.contains(_selectedCategory) ? _selectedCategory : null,
                hint: const Text('Pilih Kategori'),
                items: _categories.map((c) {
                  return DropdownMenuItem<String>(
                    value: c,
                    child: Text(c),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() => _selectedCategory = v);
                  }
                },
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
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(_isSubmitting ? 'Menyimpan...' : 'Simpan Perubahan'),
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textMuted,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Batal'),
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
}