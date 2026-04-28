# Sisforbis ERP - Sistem Informasi Bisnis Terintegrasi

[![Flutter](https://img.shields.io/badge/Framework-Flutter-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20Windows%20%7C%20macOS-0175C2)](https://flutter.dev)
[![Tax Compliance](https://img.shields.io/badge/Tax-Indonesia%20UU%20HPP-green)](https://pajak.go.id)

**Sisforbis ERP** adalah aplikasi manajemen bisnis modular yang dirancang khusus untuk memenuhi kebutuhan UMKM di Indonesia. Aplikasi ini menggabungkan kemudahan penggunaan dengan kepatuhan hukum perpajakan Indonesia (UU HPP) dalam balutan desain antarmuka modern yang inklusif.

---

## 🚀 Fitur Utama

### 🛠 Arsitektur Modular (Odoo-Style)
Aplikasi terbagi menjadi modul-modul independen yang saling terintegrasi:
- **ERP (Inventory):** Manajemen stok dengan proteksi stok negatif dan kalkulator inline.
- **Finance (Laporan):** Audit riwayat transaksi lengkap (In/Out) beserta pelaporan laba/rugi.
- **HR (Human Resources):** Manajemen data karyawan, jabatan, dan struktur gaji.
- **Expense (Biaya):** Pencatatan biaya operasional (listrik, sewa, dll) untuk akurasi laba bersih.
- **CRM (Customer):** Database pelanggan dan log interaksi layanan.
- **Queue:** Sistem antrean digital untuk pelayanan fisik.

### 🇮🇩 Otomasi Pajak Indonesia (UU HPP)
Fitur unik yang jarang ditemukan pada aplikasi sejenis:
- **PPN (Pajak Pertambahan Nilai):** Otomasi penghitungan 11% (adjustable) pada setiap transaksi penjualan.
- **PPh Final UMKM:** Estimasi otomatis beban pajak 0,5% dari omzet bruto sesuai PP No. 55 Tahun 2022.
- **Transparansi Keuangan:** Pemisahan antara Omzet Bruto, PPN Terpungut, dan Laba Bersih.

### ♿ Aksesibilitas & Inklusivitas
Didesain agar bisa digunakan oleh siapa saja:
- **Font Ramah Disleksia:** Pilihan font khusus (Comic Neue) untuk membantu pengguna dengan hambatan membaca.
- **Skala Teks Dinamis:** Ukuran font yang dapat disesuaikan (Kecil - Ekstra Besar).
- **Dark Mode:** Tema gelap yang elegan untuk kenyamanan mata.
- **Modern UI:** Menggunakan font **Outfit** untuk tampilan profesional.

### 📄 Master Reporting
- **Ekspor PDF Komplet:** Menghasilkan laporan PDF "Master" yang mencakup status keuangan, aset barang, data karyawan, hingga database pelanggan.
- **Share to Gmail:** Integrasi langsung dengan intent sistem untuk mengirim laporan via email.

---

## 🛠 Teknologi yang Digunakan
- **Framework:** Flutter (Dart)
- **Database:** SQLite (via `sqflite_common_ffi` untuk desktop)
- **Visualization:** `fl_chart`
- **PDF Engine:** `pdf` & `printing`
- **Logic Engine:** `math_expressions` (untuk kalkulator inline)

---

## 📖 Cara Penggunaan

### 1. Instalasi
```bash
# Clone repository ini
git clone https://github.com/username/sisforbis.git

# Masuk ke direktori
cd sisforbis

# Install dependensi
flutter pub get
```

### 2. Menjalankan Aplikasi
```bash
# Untuk Linux/Desktop
flutter run -d linux
```

### 3. Tips Cepat
- **Kalkulator:** Saat menginput harga atau jumlah, Anda bisa mengetik `20000 + 5000` lalu tekan *Enter/Tab*, maka nilai akan otomatis menjadi `25000`.
- **Reset Data:** Jika ingin menghapus semua data, klik ikon merah di navigasi bawah dan ketik kata **"HAPUS"** (kapital) untuk konfirmasi.
- **Ganti Font:** Buka menu **Aksesibilitas** (ikon orang) untuk mengganti font ke gaya Disleksia atau Resmi.

---

## 📝 Catatan Pengembangan
Aplikasi ini dikembangkan sebagai solusi *all-in-one* yang ringan namun bertenaga untuk membantu digitalisasi UMKM di Indonesia, memastikan pencatatan keuangan yang rapi dan patuh pajak.

**Developed by:** Gemini CLI Agent
**Status:** Stable v2.0 (Modular Edition)
# sisforbis_tugas_psti
