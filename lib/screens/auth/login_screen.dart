// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey           = GlobalKey<FormState>();
  final _emailController   = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword    = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final error = await context.read<AuthProvider>().login(
      email:    _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:          Text(error),
          backgroundColor:  Colors.red,
          behavior:         SnackBarBehavior.floating,
          shape:            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
    // Jika sukses, AuthWrapper otomatis redirect ke HomeScreen / SellerHomeScreen
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end:   Alignment.bottomRight,
            colors: [AppTheme.primary, AppTheme.secondary, Color(0xFF0F3460)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // Logo
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.accent,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: AppTheme.accent.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: const Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 48),
                  ),
                  const SizedBox(height: 24),
                  Text(AppConstants.appName,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1,
                    )),
                  const SizedBox(height: 8),
                  Text('Belanja sepeda impianmu dengan mudah!',
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
                  const SizedBox(height: 48),

                  // Form Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 30, offset: const Offset(0, 10))],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Masuk', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                          const SizedBox(height: 4),
                          Text('Selamat datang kembali!', style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
                          const SizedBox(height: 24),

                          // Email
                          const Text('Email', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(hintText: 'Masukkan email', prefixIcon: Icon(Icons.email_outlined)),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Email tidak boleh kosong';
                              if (!v.contains('@'))        return 'Format email tidak valid';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password
                          const Text('Password', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller:  _passwordController,
                            obscureText: _obscurePassword,
                            decoration:  InputDecoration(
                              hintText:   'Masukkan password',
                              prefixIcon: const Icon(Icons.lock_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Password tidak boleh kosong';
                              if (v.length < 6)           return 'Password minimal 6 karakter';
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Tombol Login
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: auth.isLoading ? null : _login,
                              child: auth.isLoading
                                  ? const SizedBox(height: 20, width: 20,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Text('Masuk'),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Link ke Register
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Belum punya akun? ', style: TextStyle(color: Colors.grey.shade600)),
                              GestureDetector(
                                onTap: () => Navigator.push(context,
                                    MaterialPageRoute(builder: (_) => const RegisterScreen())),
                                child: const Text('Daftar Sekarang',
                                    style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}