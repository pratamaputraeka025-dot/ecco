// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import '../utils/supabase_config.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _initSession();
    supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedOut) {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  Future<void> _initSession() async {
    final session = supabase.auth.currentSession;
    if (session != null) {
      await _loadProfile(session.user);
    }
  }

  Future<void> _loadProfile(User user) async {
    try {
      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      _currentUser = UserModel.fromMap(data, user.email ?? '');
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }

  Future<String?> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'phone': phone,
          'role': role,
        },
      );

      if (response.user == null) {
        return 'Registrasi gagal, coba lagi';
      }

      await Future.delayed(const Duration(milliseconds: 500));
      await _loadProfile(response.user!);
      return null;
    } on AuthException catch (e) {
      return _translateAuthError(e.message);
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return 'Login gagal';
      }

      await _loadProfile(response.user!);
      return null;
    } on AuthException catch (e) {
      return _translateAuthError(e.message);
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<String?> updateProfile({String? name, String? phone, String? address}) async {
    if (_currentUser == null) return 'Belum login';
    _isLoading = true;
    notifyListeners();

    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
        if (address != null) 'address': address,
      };

      await supabase.from('profiles').update(updates).eq('id', _currentUser!.id);

      final user = supabase.auth.currentUser!;
      await _loadProfile(user);
      return null;
    } catch (e) {
      return 'Gagal update profile: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> updateFullProfile({
    String? name,
    String? phone,
    String? address,
    String? avatarUrl,
    DateTime? birthDate,
    String? gender,
  }) async {
    if (_currentUser == null) return 'Belum login';
    _isLoading = true;
    notifyListeners();

    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
        if (address != null) 'address': address,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        if (birthDate != null) 'birth_date': birthDate.toIso8601String().split('T')[0],
        if (gender != null) 'gender': gender,
      };

      await supabase.from('profiles').update(updates).eq('id', _currentUser!.id);

      final user = supabase.auth.currentUser!;
      await _loadProfile(user);
      return null;
    } catch (e) {
      return 'Gagal update profile: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _translateAuthError(String message) {
    if (message.contains('already registered') || message.contains('already exists')) {
      return 'Email sudah terdaftar';
    }
    if (message.contains('Invalid login credentials')) {
      return 'Email atau password salah';
    }
    if (message.contains('Email not confirmed')) {
      return 'Email belum dikonfirmasi, cek inbox kamu';
    }
    if (message.contains('Password should be')) {
      return 'Password minimal 6 karakter';
    }
    return message;
  }
}