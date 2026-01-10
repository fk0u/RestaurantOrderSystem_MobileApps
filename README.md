# Restaurant Order System (POS Enterprise Edition)

**Sistem Point of Sale (POS) Restoran Full-Stack dengan Integrasi Flutter & SQLite.**

Project ini merupakan implementasi referensi untuk aplikasi manajemen restoran modern. Dirancang dengan arsitektur **Clean Architecture (MVVM + Repository Pattern)**, aplikasi ini tidak hanya sekadar *demo UI*, melainkan sistem yang fungsional penuh dengan logika bisnis yang kompleks, manajemen inventaris, dan sinkronisasi data lokal.

---

## 🌟 Fitur Unggulan (Enterprise Grade)

### 1. Role-Based Access Control (RBAC)
Sistem keamanan berbasis peran yang membatasi akses fitur sesuai jabatan pengguna. Login divalidasi langsung terhadap database SQLite lokal terenkripsi.

| Role | Akses Fitur Utama | Kredensial Demo |
|------|-------------------|-----------------|
| **Admin** | Dashboard Analitik, Laporan Pendapatan, Manajemen User | `admin@resto.com` / `admin123` |
| **Kasir** | Denah Meja Visual, POS Checkout, Cetak Struk, Status Meja | `cashier@resto.com` / `cashier123` |
| **Kitchen** | Kitchen Display System (KDS), Update Status Pesanan | `kitchen@resto.com` / `kitchen123` |
| **Customer** | Aplikasi Menu, Keranjang Belanja, Self-Order | `user@gmail.com` / `user123` |

### 2. Manajemen Meja Visual (Visual Table Management)
Fitur unggulan untuk kasir memantau kondisi restoran secara *real-time*.
- **Indikator Warna**: Hijau (Kosong), Merah (Terisi), Kuning (Reservasi).
- **Interaksi Langsung**: Klik meja kosong untuk membuka pesanan baru (Open Bill).
- **Koordinat Visual**: Meja dipetakan dalam grid (X,Y) untuk representasi layout fisik.

### 3. Smart Inventory System
Sistem stok cerdas yang mencegah penjualan melebihi ketersediaan.
- **Auto-Deduction**: Stok berkurang otomatis (transaksional) begitu pesanan dikonfirmasi (`confirmed`).
- **Low Stock Guard**: Item dengan Stok 0 otomatis dinonaktifkan di menu pelanggan dan kasir.
- **Fail-Safe**: Transaksi akan ditolak jika stok tiba-tiba habis saat proses checkout.

### 4. Advanced Payment & Billing Engine
Mesin kasir yang menangani kalkulasi keuangan secara presisi.
- **Tax Engine**: PPN 11% dikalkulasi dari subtotal.
- **Service Charge**: Biaya layanan 5% otomatis ditambahkan.
- **Metode Pembayaran**: Dukungan Cash dan QRIS (dengan simulasi *Dynamic QR*).
- **Digital Receipt**: Menghasilkan struk belanja lengkap dengan Order ID, perincian item, dan total bayar.

### 5. Seamless Order Lifecycle
Alur pesanan yang terintegrasi dari depan ke belakang tanpa jeda.
1.  **Order Created**: Kasir/Customer membuat pesanan -> Status `Sedang Diproses`.
2.  **Kitchen Protocol**: Tampil di layar Dapur. Chef memasak -> Status diubah `Sedang Dimasak` -> `Siap Saji`.
3.  **Serving**: Pelayan mengantar -> Status `Selesai`.
4.  **Billing**: Data masuk ke rekap penjualan Admin.

---

## 🏗️ Arsitektur & Teknologi

Project ini dibangun dengan standar industri yang ketat untuk memastikan skalabilitas dan kemudahan perawatan (maintainability).

- **Framework**: Flutter (Dart)
- **State Management**: **Riverpod** (Provider + StateNotifier)
- **Database**: **SQLite** (`sqflite`)
- **Navigation**: **GoRouter** (Deep linking & Route Guards)
- **Architecture**: Clean Architecture Separation
    - `Presentation Layer`: UI, Controllers (Riverpod).
    - `Domain Layer`: Entities, Repository Interfaces.
    - `Data Layer`: Repository Implementation, DTOs, Data Sources (SQLite).

### Skema Database (SQLite)
Aplikasi menggunakan database relasional `resto_app.db` dengan skema berikut:

1.  **`users`**: Menyimpan data autentikasi (id, email, password_hash, role).
2.  **`products`**: Katalog menu (id, nama, harga, stok, gambar, kategori).
3.  **`restaurant_tables`**: Data meja fisik (id, nomor, kapasitas, status, koordinat).
4.  **`orders`**: Header transaksi (id, user_id, total, status, timestamp, table_id).
5.  **`order_items`**: Detail item per transaksi (fk_order_id, product_id, qty, modifiers, note).
6.  **`settings`**: Konfigurasi global (tax_rate, service_charge, resto_name).

---

## 📖 Panduan Penggunaan (User Manual)

### Skenario 1: Kasir Menerima Tamu (Dine-in)
1.  Login sebagai **Kasir** (`cashier@resto.com`).
2.  Buka menu **"Meja"**. Lihat denah meja.
3.  Pilih Meja yang **Hijau (Kosong)** -> Klik **"Buat Pesanan Baru"**.
4.  Status Meja berubah menjadi **Merah (Terisi)**.
5.  Aplikasi beralih ke Menu. Pilih makanan -> Checkout.
6.  Pilih metode bayar (Tunai/QRIS). Konfirmasi.
7.  Muncul **Struk Digital**. Meja kini berstatus terisi sampai checkout selesai.

### Skenario 2: Dapur Memproses Pesanan
1.  Login sebagai **Kitchen** (`kitchen@resto.com`).
2.  Lihat **Dashboard Dapur**. Pesanan baru muncul paling atas.
3.  Masak pesanan. Klik icon status untuk update:
    - *Sedang Diproses* -> *Sedang Dimasak*
    - *Sedang Dimasak* -> *Siap Saji* (Pelayan akan dipanggil).
4.  Klik **"Selesai"** jika pesanan sudah diantar habis ke meja.

### Skenario 3: Admin Audit Harian
1.  Login sebagai **Admin** (`admin@resto.com`).
2.  Lihat **Dashboard Ringkasan**.
3.  Cek **Total Penjualan** dan **Jumlah Transaksi** hari ini.
4.  Data diambil *real-time* `SUM(totalPrice)` dari tabel `orders`.

---

## 🛠️ Instalasi & Setup

### Prasyarat
- Flutter SDK 3.x ke atas.
- Android Studio / VS Code dengan ekstensi Flutter.

### Langkah Instalasi
1.  **Clone Repository**
    ```bash
    git clone https://github.com/Start-Up-Sakti/Super_Restaurant_App_2025.git
    cd RestaurantOrderSystem_MobileApps
    ```

2.  **Install Dependencies**
    ```bash
    flutter pub get
    ```

3.  **Jalankan Aplikasi**
    ```bash
    flutter run
    ```
    *Database akan otomatis dibuat (`version: 2`) dan diisi data awal (seeding) pada peluncuran pertama.*

---

## ⚠️ Troubleshooting

- **Error: "Table not found"**: Hapus aplikasi dari emulator/HP, lalu install ulang untuk memicu `onCreate` database baru.
- **Stok Habis tapi masih tampil**: Pastikan Anda me-refresh halaman dashboard Admin/Kasir karena Flutter menyimpan cache state sementara.
- **Lint Error**: Jalankan `flutter analyze` untuk memastikan kode bersih sebelum commit.

---

**© 2026 Resto Nusantara Team | Powered by KILOUX AI**
*Membangun Solusi Digital Restoran Masa Depan.*
