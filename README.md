# 🛍️ ShopNow - Aplikasi E-Commerce Flutter

Aplikasi e-commerce lengkap dengan Flutter untuk keperluan tugas kuliah.

## ✨ Fitur Lengkap

- 🔐 **Login & Register** - Autentikasi pengguna dengan validasi
- 🏠 **Home Page** - Banner promo, kategori, dan grid produk
- 🔍 **Search & Filter** - Pencarian dan filter berdasarkan kategori
- 📦 **Detail Produk** - Gambar, deskripsi, rating, pilih jumlah
- 🛒 **Keranjang Belanja** - Tambah, kurangi, hapus item
- 📋 **Checkout** - Isi alamat, pilih kurir pengiriman
- 💳 **Pembayaran** - Pilihan metode: VA Bank, E-Wallet, COD, Kartu
- ✅ **Order Success** - Konfirmasi pesanan dengan tracking status

## 📁 Struktur File

```
lib/
├── main.dart                          ← Entry point aplikasi
├── models/
│   └── models.dart                    ← Model: Product, CartItem, User, Order
├── providers/
│   ├── auth_provider.dart             ← State management autentikasi
│   └── providers.dart                 ← CartProvider & ProductProvider
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart          ← Halaman login
│   │   └── register_screen.dart       ← Halaman register
│   ├── home/
│   │   └── home_screen.dart           ← Halaman utama (beranda)
│   ├── product/
│   │   └── product_detail_screen.dart ← Detail produk
│   ├── cart/
│   │   └── cart_screen.dart           ← Keranjang belanja
│   └── checkout/
│       ├── checkout_screen.dart        ← Halaman checkout
│       ├── payment_screen.dart         ← Pilih metode pembayaran
│       └── order_success_screen.dart   ← Pesanan berhasil
├── widgets/
│   ├── product_card.dart              ← Widget kartu produk
│   └── category_chip.dart             ← Widget chip kategori
└── utils/
    └── app_theme.dart                 ← Tema & konstanta aplikasi
```

## 🚀 Cara Menjalankan

### Prasyarat
- Flutter SDK 3.0 ke atas
- VS Code + extension Flutter & Dart
- Android Studio / Emulator / HP fisik

### Langkah-langkah

1. **Buka Terminal di VS Code**, lalu masuk ke folder project:
   ```bash
   cd flutter_ecommerce
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Jalankan aplikasi:**
   ```bash
   flutter run
   ```

4. **Atau pilih device** di VS Code (pojok kanan bawah) lalu tekan `F5`

### 🔑 Akun Demo Login
| Email | Password |
|-------|----------|
| demo@shopnow.com | 123456 |
| user@test.com | password |

## 📱 Flow Aplikasi

```
Login/Register
     ↓
Beranda (Home)
  - Lihat produk, search, filter kategori
     ↓
Detail Produk
  - Pilih jumlah → Tambah ke keranjang
     ↓
Keranjang (Cart)
  - Edit jumlah, lihat subtotal
     ↓
Checkout
  - Isi alamat, pilih kurir
     ↓
Pembayaran
  - Pilih metode (VA Bank, E-Wallet, COD)
     ↓
Order Success ✅
```

## 🛠️ Tech Stack

- **Framework:** Flutter
- **State Management:** Provider
- **UI:** Material Design 3
- **Font:** Google Fonts (Poppins)
- **Gambar:** cached_network_image

## 📦 Dependencies (pubspec.yaml)

```yaml
dependencies:
  provider: ^6.1.1          # State management
  shared_preferences: ^2.2.2 # Local storage
  google_fonts: ^6.1.0       # Font Poppins
  cached_network_image: ^3.3.1 # Optimasi gambar
  badges: ^3.1.2             # Badge keranjang
  fluttertoast: ^8.2.4       # Notifikasi toast
  intl: ^0.19.0              # Format angka/tanggal
```
