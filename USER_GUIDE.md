# Panduan Penggunaan Aplikasi Calorie Tracker

Aplikasi Calorie Tracker dirancang untuk membantu Anda memantau asupan kalori dan makronutrien harian, mencatat aktivitas, serta melacak progres berat badan Anda. Panduan ini akan menjelaskan setiap fitur utama aplikasi.

## 1. Registrasi Akun Baru

Untuk pengguna baru, Anda perlu mendaftar terlebih dahulu:
1.  Dari halaman `Welcome Screen`, pilih opsi 'Daftar'.
2.  Masukkan `Email` dan `Kata Sandi` Anda. Pastikan kata sandi minimal 6 karakter dan konfirmasi kata sandi cocok.
3.  Setelah berhasil, Anda akan diarahkan ke alur *onboarding* untuk mengisi detail profil.

## 2. Login

Jika Anda sudah memiliki akun, Anda bisa masuk:
1.  Dari halaman `Welcome Screen`, pilih opsi 'Masuk'.
2.  Masukkan `Email` dan `Kata Sandi` yang sudah terdaftar.
3.  Jika kredensial valid, Anda akan masuk ke `Dashboard Screen`.

## 3. Alur Onboarding (Pengaturan Profil Awal)

Setelah registrasi, Anda akan diminta untuk mengisi informasi pribadi untuk perhitungan kalori yang akurat. Ikuti langkah-langkah berikut:
1.  **Input Nama:** Masukkan nama lengkap Anda.
2.  **Pilih Jenis Kelamin:** Pilih jenis kelamin Anda (Laki-laki/Perempuan).
3.  **Pilih Tahun Lahir:** Pilih tanggal lahir Anda menggunakan pemilih tanggal. Pastikan usia Anda antara 15 dan 80 tahun.
4.  **Input Tinggi Badan:** Masukkan tinggi badan Anda dalam sentimeter (cm).
5.  **Input Berat Badan:** Masukkan berat badan Anda dalam kilogram (kg).
6.  **Pilih Tingkat Aktivitas:** Pilih tingkat aktivitas harian Anda (Sangat Sedentari, Ringan Aktif, Cukup Aktif, Sangat Aktif, Ekstra Aktif).
7.  **Pilih Tujuan:** Pilih tujuan utama Anda (Menjaga Berat Badan, Menurunkan Berat Badan, Menambah Berat Badan).
8.  **Halaman Ringkasan:** Anda akan melihat ringkasan profil, estimasi kebutuhan kalori harian, dan makronutrien. Data ini akan disimpan secara lokal.

## 4. Dashboard

Halaman utama aplikasi yang menampilkan ringkasan harian Anda:
*   **Tanggal:** Anda dapat mengubah tanggal untuk melihat riwayat konsumsi makanan dan aktivitas pada hari-hari sebelumnya.
*   **Ringkasan Kalori:** Menampilkan target kalori harian, kalori yang dikonsumsi, dan kalori yang dibakar.
*   **Lingkaran Makronutrien:** Menampilkan progres konsumsi Protein, Lemak, dan Karbohidrat terhadap target harian Anda.
*   **Daftar Makanan:** Menampilkan semua makanan yang telah Anda catat untuk hari yang dipilih, dikelompokkan berdasarkan jenis hidangan (Sarapan, Makan Siang, Makan Malam, Snack).
*   **Tombol Tambah:** Tombol '+' di kanan bawah untuk menambahkan makanan, aktivitas, atau mencatat berat badan.
*   **Ikon Pengaturan:** Ikon *gear* di kanan atas `AppBar` untuk masuk ke halaman `Pengaturan`.

## 5. Menambahkan Makanan

Untuk mencatat asupan makanan Anda:
1.  Dari `Dashboard`, tekan tombol '+', lalu pilih 'Tambah Makanan'.
2.  **Cari Makanan:** Gunakan *search bar* untuk mencari makanan dari daftar yang sudah disediakan.
3.  **Pilih Makanan atau Tambah Kustom:**
    *   **Pilih dari Daftar:** Ketuk kartu makanan yang ingin Anda tambahkan.
    *   **Tambah Makanan Kustom:** Tekan tombol 'Tambah Makanan Baru' untuk membuat entri makanan kustom.
4.  **Halaman Detail Makanan (untuk makanan yang dipilih/kustom):**
    *   Pilih `Jenis Hidangan` (Sarapan, Makan Siang, Makan Malam, Snack).
    *   Masukkan `Jumlah` dalam gram atau porsi.
    *   Anda dapat mengunggah gambar makanan (opsional).
    *   Tekan 'Simpan Makanan'.

## 6. Menambahkan Aktivitas

Untuk mencatat aktivitas fisik yang Anda lakukan:
1.  Dari `Dashboard`, tekan tombol '+', lalu pilih 'Tambah Aktivitas'.
2.  Pilih `Jenis Aktivitas` (misalnya, Berjalan Kaki, Berlari, Bersepeda, dll.).
3.  Masukkan `Durasi Aktivitas` dalam menit. Kalori yang dibakar akan dihitung secara otomatis.
4.  Tekan 'Simpan Aktivitas'.

## 7. Mencatat Berat Badan

Untuk melacak progres berat badan Anda:
1.  Dari `Dashboard`, tekan tombol '+', lalu pilih 'Catat Berat Badan'.
2.  Masukkan `Berat Badan` Anda dalam kilogram (kg).
3.  Tekan 'Simpan Berat Badan'.

## 8. Statistik

Untuk melihat tren berat badan dan kalori:
*   Akses halaman ini melalui `Bottom Navigation Bar` di `Dashboard`.
*   Anda akan melihat grafik riwayat berat badan Anda dan ringkasan kalori harian.

## 9. Profil Pengguna

Untuk melihat dan mengelola informasi profil Anda:
*   Akses halaman ini melalui `Bottom Navigation Bar` di `Dashboard`.
*   Menampilkan detail informasi pribadi (Nama, Gender, Tahun Lahir, Tinggi Badan, Berat Badan, Tingkat Aktivitas, Tujuan, Kalori Harian, Makronutrien).
*   **Tombol 'Ubah Informasi Pribadi':** Mengarahkan Anda ke halaman baru untuk memperbarui detail profil Anda.

## 10. Pengaturan

Akses `Pengaturan` melalui ikon *gear* di `AppBar` `Dashboard`.

### 10.1. Logout
*   Tombol 'Logout' akan menghapus semua data pengguna lokal dari aplikasi dan mengarahkan Anda kembali ke `Welcome Screen`.

### 10.2. Ekspor Data
*   Tombol 'Ekspor Data' akan menyimpan semua data aplikasi Anda (profil, makanan, aktivitas, berat badan) ke dalam *file* JSON (`calorie_tracker_data.json`) di perangkat Anda. Ini berguna untuk membuat cadangan data.

### 10.3. Impor Data
*   Tombol 'Impor Data' memungkinkan Anda memilih *file* JSON yang sebelumnya diekspor. Setelah *file* dipilih, data akan dimuat kembali ke aplikasi, menimpa data yang ada, dan aplikasi akan dimulai ulang.

## 11. Memperbarui Informasi Pribadi

*   Dari halaman `Profil`, tekan tombol 'Ubah Informasi Pribadi'.
*   Anda dapat memperbarui nama, tinggi badan, berat badan, tingkat aktivitas, dan tujuan Anda.
*   Setelah perubahan disimpan, kebutuhan kalori dan makronutrien harian Anda akan dihitung ulang.

--- 