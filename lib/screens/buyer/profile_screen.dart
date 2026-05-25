// lib/screens/buyer/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _avatarUrlCtrl;
  DateTime? _selectedBirthDate;
  String? _selectedGender;
  bool _isEditing = false;
  bool _isSaving = false;

  final List<Map<String, String>> _genderOptions = [
    {'value': 'L', 'label': 'Laki-laki'},
    {'value': 'P', 'label': 'Perempuan'},
    {'value': '', 'label': 'Tidak disebutkan'},
  ];

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser!;
    _nameCtrl = TextEditingController(text: user.name);
    _phoneCtrl = TextEditingController(text: user.phone);
    _addressCtrl = TextEditingController(text: user.address);
    _avatarUrlCtrl = TextEditingController(text: user.avatarUrl ?? '');
    _selectedBirthDate = user.birthDate;
    _selectedGender = user.gender;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _avatarUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);

    final err = await context.read<AuthProvider>().updateFullProfile(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      avatarUrl: _avatarUrlCtrl.text.trim().isNotEmpty 
          ? _avatarUrlCtrl.text.trim() 
          : null,
      birthDate: _selectedBirthDate,
      gender: _selectedGender,
    );

    setState(() {
      _isSaving = false;
      _isEditing = false;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(err ?? 'Profil berhasil diperbarui ✅'),
        backgroundColor: err != null ? Colors.red : AppTheme.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedBirthDate) {
      setState(() => _selectedBirthDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser!;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Profil Saya'),
        actions: [
          // TOMBOL EDIT - INI YANG ANDA CARI!
          if (!_isEditing)
            TextButton.icon(
              onPressed: () => setState(() => _isEditing = true),
              icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 18),
              label: const Text('Edit', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.accent, width: 2),
              image: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(user.avatarUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                ? Center(
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accent,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 12),

          Text(user.email, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
          const SizedBox(height: 4),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              user.isPenjual ? '🏪 Penjual' : '🛒 Pembeli',
              style: const TextStyle(
                color: AppTheme.accent,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Form
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _fieldLabel('Avatar URL'),
              const SizedBox(height: 8),
              TextField(
                controller: _avatarUrlCtrl,
                enabled: _isEditing,
                decoration: const InputDecoration(
                  hintText: 'https://...',
                  prefixIcon: Icon(Icons.image_outlined),
                ),
              ),
              const SizedBox(height: 16),

              _fieldLabel('Nama Lengkap'),
              const SizedBox(height: 8),
              TextField(
                controller: _nameCtrl,
                enabled: _isEditing,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),

              _fieldLabel('Nomor Telepon'),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneCtrl,
                enabled: _isEditing,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 16),

              _fieldLabel('Tanggal Lahir'),
              const SizedBox(height: 8),
              InkWell(
                onTap: _isEditing ? () => _selectBirthDate(context) : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                    color: _isEditing ? Colors.white : Colors.grey.shade50,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.cake_outlined, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedBirthDate != null
                              ? '${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}'
                              : 'Belum diisi',
                          style: TextStyle(
                            color: _selectedBirthDate != null 
                                ? AppTheme.textDark 
                                : Colors.grey.shade500,
                          ),
                        ),
                      ),
                      if (_isEditing) const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _fieldLabel('Jenis Kelamin'),
              const SizedBox(height: 8),
              if (!_isEditing)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade50,
                  ),
                  child: Text(
                    _genderOptions.firstWhere(
                      (g) => g['value'] == _selectedGender,
                      orElse: () => _genderOptions.last,
                    )['label']!,
                  ),
                )
              else
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  items: _genderOptions.map((opt) {
                    return DropdownMenuItem(
                      value: opt['value'],
                      child: Text(opt['label']!),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedGender = val),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
              const SizedBox(height: 16),

              _fieldLabel('Alamat Pengiriman'),
              const SizedBox(height: 8),
              TextField(
                controller: _addressCtrl,
                enabled: _isEditing,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Masukkan alamat lengkap...',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
            ]),
          ),

          if (_isEditing) ...[
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSaving ? null : () => setState(() => _isEditing = false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textMuted,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(_isSaving ? 'Menyimpan...' : 'Simpan'),
                ),
              ),
            ]),
          ],
        ]),
      ),
    );
  }

  Widget _fieldLabel(String text) => Text(
    text,
    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
  );
}