// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import '../models/models.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;

  // Demo users
  final List<Map<String, String>> _demoUsers = [
    {
      'email': 'demo@shopnow.com',
      'password': '123456',
      'name': 'Budi Santoso',
      'phone': '081234567890',
      'address': 'Jl. Sudirman No. 10, Jakarta Selatan',
    },
    {
      'email': 'user@test.com',
      'password': 'password',
      'name': 'Siti Rahayu',
      'phone': '085678901234',
      'address': 'Jl. Gatot Subroto No. 5, Jakarta Pusat',
    },
  ];

  Future<String?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1)); // Simulate API call

    final user = _demoUsers.firstWhere(
      (u) => u['email'] == email && u['password'] == password,
      orElse: () => {},
    );

    _isLoading = false;

    if (user.isNotEmpty) {
      _currentUser = UserModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: user['name']!,
        email: user['email']!,
        phone: user['phone']!,
        address: user['address']!,
      );
      notifyListeners();
      return null; // Success
    } else {
      notifyListeners();
      return 'Email atau password salah';
    }
  }

  Future<String?> register(String name, String email, String password, String phone) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    final exists = _demoUsers.any((u) => u['email'] == email);
    if (exists) {
      _isLoading = false;
      notifyListeners();
      return 'Email sudah terdaftar';
    }

    _currentUser = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      phone: phone,
      address: '',
    );

    _isLoading = false;
    notifyListeners();
    return null;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
