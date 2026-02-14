# Restaurant Order System (Aplikasi Pemesanan Restoran)

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![NodeJS](https://img.shields.io/badge/node.js-6DA55F?style=for-the-badge&logo=node.js&logoColor=white)
![Express.js](https://img.shields.io/badge/express.js-%23404d59.svg?style=for-the-badge&logo=express&logoColor=%2361DAFB)
![MySQL](https://img.shields.io/badge/mysql-4479A1.svg?style=for-the-badge&logo=mysql&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-blue.svg?style=for-the-badge)

Aplikasi manajemen restoran **Full-Stack** yang komprehensif, dibangun dengan **Flutter** untuk antarmuka pengguna (Mobile App) dan **Node.js/MySQL** untuk backend server. Solusi ini mencakup seluruh siklus operasional restoran mulai dari pelanggan memesan, dapur memproses pesanan, hingga manajemen oleh admin.

---

## Fitur Unggulan

Aplikasi ini dirancang dengan **Role-Based Access Control (RBAC)** untuk memastikan setiap pengguna mendapatkan pengalaman yang sesuai dengan perannya.

### Pelanggan (Customer)
*   **Menu Digital Interaktif**: Menjelajahi menu dengan kategori yang jelas, pencarian cepat, dan tampilan visual menarik.
*   **Keranjang Belanja Floating**: Tombol keranjang yang melayang untuk akses cepat dan ringkasan pesanan real-time.
*   **Logika Stok Pintar**: Menu tidak akan hilang dari daftar meski stok menipis, hanya tombol tambah yang dinonaktifkan jika stok 0.
*   **Restricted Navigation**: Antarmuka yang disederhanakan tanpa tab manajemen meja yang membingungkan.
*   **Status Pesanan**: Melacak status pesanan dari "Menunggu" -> "Dimasak" -> "Siap Saji".

### Dapur (Kitchen)
*   **Kitchen Display System (KDS)**: Tampilan khusus untuk melihat pesanan masuk secara real-time.
*   **Manajemen Status**: Menandai item yang sedang dimasak atau sudah selesai dengan satu ketukan.
*   **Real-time Updates**: Notifikasi untuk pesanan baru.

### Pelayan (Staff)
*   **Manajemen Pesanan**: Membuat dan mengelola pesanan untuk pelanggan yang memesan di tempat (dine-in).
*   **Pemrosesan Pembayaran**: Menangani pembayaran tunai maupun QRIS digital.
*   **Status Meja**: Melihat tata letak meja dan status ketersediaannya (Kosong, Terisi, Reservasi).

### Admin
*   **Dashboard Analytics**: Ringkasan penjualan, total pesanan, dan pendapatan harian.
*   **Manajemen Produk**: Tambah, Edit, Hapus menu, serta pengaturan stok.
*   **Manajemen Kategori**: Mengatur pengelompokan menu makanan/minuman.
*   **Pengaturan Meja**: Mengatur jumlah dan kapasitas meja restoran.

---

## Teknologi yang Digunakan

### Frontend (Mobile App)
*   **Framework**: [Flutter](https://flutter.dev/) (Dart)
*   **State Management**: [Riverpod](https://riverpod.dev/) (Caching, Provider, StateNotifier)
*   **Routing**: [GoRouter](https://pub.dev/packages/go_router) (Deep linking, navigation stack)
*   **Networking**: REST API Integration (Dio/Http)
*   **Code Style**: Clean Architecture & Feature-first structure.

### Backend (Server)
*   **Runtime**: [Node.js](https://nodejs.org/)
*   **Framework**: [Express.js](https://expressjs.com/)
*   **Database**: [MySQL](https://www.mysql.com/) (Relational Data)
*   **Driver**: `mysql2` dengan dukungan Pool Connection.
*   **Security**: Basic Token Auth & CORS enabled.

---

## Panduan Instalasi (Getting Started)

Ikuti langkah-langkah ini untuk menjalankan sistem di lingkungan lokal Anda.

### Prasyarat
*   **Flutter SDK**: Versi 3.x.x atau terbaru.
*   **Node.js**: Versi 18.x atau terbaru.
*   **MySQL Server**: (Bisa menggunakan XAMPP, Laragon, Docker, atau MySQL Workbench).

### 1. Persiapan Database
1.  Buat database baru di MySQL dengan nama `RestoMobile`.
2.  Import skema database:
    *   Jalankan perintah SQL yang ada di file `server/schema.sql`.
3.  Isi data awal (Seeding):
    ```bash
    cd server
    node seed.js
    ```
    *Dapat mengisi database dengan user default, kategori, produk, dan meja.*

### 2. Menjalankan Backend Server
1.  Masuk ke folder server:
    ```bash
    cd server
    ```
2.  Install library/dependency:
    ```bash
    npm install
    ```
3.  Jalankan server:
    ```bash
    node index.js
    ```
    *Server akan berjalan di port 3000 secara default (`http://localhost:3000`).*

### 3. Menjalankan Aplikasi Mobile
1.  Kembali ke root folder proyek.
2.  Ambil paket dependency Flutter:
    ```bash
    flutter pub get
    ```
3.  Jalankan aplikasi (pilih emulator atau device fisik):
    ```bash
    flutter run
    ```

> **Catatan Penting**: Pastikan `baseUrl` di konfigurasi Flutter Anda (`lib/core/constants/api_constants.dart` atau sejenisnya) mengarah ke IP Address komputer Anda (misal: `http://10.0.2.2:3000` untuk Emulator Android), bukan `localhost` jika di device fisik.

---

## Akun Demo (Default Credentials)

Gunakan akun berikut untuk menguji berbagai peran dalam aplikasi:

| Peran (Role) | Email | Password | Akses Utama |
| :--- | :--- | :--- | :--- |
| **Admin** | `admin@resto.com` | `password` | Dashboard, Master Data Produk/Meja |
| **Staff** | `staff@resto.com` | `password` | Kasir, Manajemen Pesanan |
| **Kitchen** | `kitchen@resto.com` | `password` | Layar Dapur (KDS) |
| **Customer** | `user@resto.com` | `password` | Menu, Keranjang, Pesan Sendiri |

---

## Struktur Proyek

```
lib/
├── core/               # Utilitas inti (Tema, Konstanta, Router)
├── features/           # Modul fitur (Clean Arch)
│   ├── auth/           # Login & Registrasi
│   ├── menu/           # Daftar Produk & Detail
│   ├── cart/           # Manajemen Keranjang
│   ├── orders/         # Riwayat & Status Pesanan
│   ├── tables/         # Pemilihan & Denah Meja
│   ├── profile/        # Profil Pengguna
│   └── main_wrapper.dart # Navigasi Utama (Bottom Bar)
├── main.dart           # Titik Masuk Aplikasi

server/
├── index.js            # Entry Point Server Express
├── schema.sql          # Definisi Skema Database
├── seed.js             # Script Pengisi Data Awal
└── ...
```

## Kontribusi

Kontribusi sangat diterima! Silakan fork repositori ini dan buat Pull Request untuk fitur baru atau perbaikan bug.

1.  Fork Project
2.  Create Feature Branch (`git checkout -b feature/NewFeature`)
3.  Commit Changes (`git commit -m 'Add NewFeature'`)
4.  Push to Branch (`git push origin feature/NewFeature`)
5.  Open Pull Request

---

Dibuat dengan **Flutter** & **Node.js**.
