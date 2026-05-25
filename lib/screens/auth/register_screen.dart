// lib/screens/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _obscurePassword = true;
  String _selectedRole = 'pembeli'; // default role

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final error = await context.read<AuthProvider>().register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          phone: _phoneController.text.trim(),
          role: _selectedRole,
        );

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    } else {
      // Sukses → AuthWrapper otomatis redirect
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Registrasi berhasil! Selamat datang ${_nameController.text} 🎉'),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primary, AppTheme.secondary, Color(0xFF0F3460)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Header
                  Row(children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon:
                          const Icon(Icons.arrow_back_ios, color: Colors.white),
                    ),
                    const Text('Buat Akun Baru',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ]),
                  const SizedBox(height: 24),

                  // Form Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24)),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── PILIH ROLE ────────────────────────────────
                          const Text('Daftar Sebagai',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 12),
                          Row(children: [
                            _roleCard(
                              role: 'pembeli',
                              icon: Icons.shopping_cart_rounded,
                              label: 'Pembeli',
                              description: 'Cari & beli produk',
                              color: AppTheme.accent,
                            ),
                            const SizedBox(width: 12),
                            _roleCard(
                              role: 'penjual',
                              icon: Icons.storefront_rounded,
                              label: 'Penjual',
                              description: 'Jual produkmu',
                              color: AppTheme.success,
                            ),
                          ]),
                          const SizedBox(height: 20),

                          // Nama
                          _label('Nama Lengkap'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              hintText: _selectedRole == 'penjual'
                                  ? 'Nama toko'
                                  : 'Nama lengkap',
                              prefixIcon: const Icon(Icons.person_outline),
                            ),
                            validator: (v) => v == null || v.isEmpty
                                ? 'Nama tidak boleh kosong'
                                : null,
                          ),
                          const SizedBox(height: 16),

                          // Email
                          _label('Email'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                                hintText: 'Masukkan email',
                                prefixIcon: Icon(Icons.email_outlined)),
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return 'Email tidak boleh kosong';
                              if (!v.contains('@'))
                                return 'Format email tidak valid';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Telepon
                          _label('Nomor Telepon'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                                hintText: '081234567890',
                                prefixIcon: Icon(Icons.phone_outlined)),
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return 'Nomor telepon tidak boleh kosong';
                              if (v.length < 10)
                                return 'Nomor telepon tidak valid';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password
                          _label('Password'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: 'Minimal 6 karakter',
                              prefixIcon: const Icon(Icons.lock_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return 'Password tidak boleh kosong';
                              if (v.length < 6)
                                return 'Password minimal 6 karakter';
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Tombol Daftar
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: auth.isLoading ? null : _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _selectedRole == 'penjual'
                                    ? AppTheme.success
                                    : AppTheme.accent,
                              ),
                              child: auth.isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2))
                                  : Text(
                                      'Daftar sebagai ${_selectedRole == 'penjual' ? 'Penjual' : 'Pembeli'}'),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Link ke Login
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Sudah punya akun? ',
                                    style:
                                        TextStyle(color: Colors.grey.shade600)),
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: const Text('Masuk',
                                      style: TextStyle(
                                          color: AppTheme.accent,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ]),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Card pilihan role (Pembeli / Penjual)
  Widget _roleCard({
    required String role,
    required IconData icon,
    required String label,
    required String description,
    required Color color,
  }) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isSelected ? color : Colors.grey.shade200, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: isSelected ? color : Colors.grey, size: 32),
              const SizedBox(height: 8),
              Text(label,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : Colors.grey.shade600)),
              const SizedBox(height: 4),
              Text(description,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13));
}
