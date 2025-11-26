# Bug Tracking & Fixes

## Daftar Masalah

### ✅ Masalah 1: Multiple Navigation (Spam Click)
**Status:** ✅ Selesai  
**Deskripsi:** Ketika user menekan tombol navigasi lebih dari sekali (double click/spam), halaman yang terbuka menjadi banyak.  
**Solusi yang diterapkan:** Menambahkan flag `_isNavigating` untuk mencegah multiple navigation. Flag ini di-reset setelah navigasi selesai (setelah route ditutup).  
**Lokasi yang diperbaiki:** 
- DashboardScreen: Tombol Tambah Makanan, Tambah Aktivitas, dan Settings
- AddFoodScreen: Tombol tambah makanan kustom dan navigasi ke FoodDetailScreen
- StatisticsScreen: Tombol tambah berat badan

### ✅ Masalah 2: Tombol Tertutup System Navigation Bar
**Status:** ✅ Selesai  
**Deskripsi:** Pada handphone yang menggunakan tombol navigasi (bukan gesture/swipe), tombol di bagian bawah aplikasi tertutup oleh tombol navigasi bawaan HP.  
**Solusi yang diterapkan:** Menambahkan `SafeArea` dan padding bottom yang mempertimbangkan tinggi system navigation bar menggunakan `MediaQuery.of(context).padding.bottom`.  
**Lokasi yang diperbaiki:** 
- FoodDetailScreen - tombol "Tambahkan Makanan"
- AddCustomFoodScreen - tombol "Tambahkan Makanan"
- AddActivityScreen - tombol "Tambahkan Aktivitas"
- AddWeightScreen - tombol "Catat Berat Badan"

### ✅ Masalah 3: Menghapus Tombol Logout
**Status:** ✅ Selesai  
**Deskripsi:** Tombol logout di halaman settings memiliki fungsi yang sama dengan "Hapus Semua Data Aplikasi" (keduanya menghapus data user), sehingga tombol logout menjadi redundan.  
**Solusi yang diterapkan:** Menghapus tombol logout dari halaman settings. Fungsi `_logout()` tetap dipertahankan karena masih digunakan oleh fungsi `_clearAllAppData()` untuk navigasi kembali ke WelcomeScreen setelah menghapus data.  
**Lokasi yang diperbaiki:** SettingsScreen - tombol "Logout" telah dihapus

### ✅ Masalah 4: Transisi Putih Saat Perpindahan Halaman
**Status:** ✅ Selesai  
**Deskripsi:** Ketika berpindah halaman (contoh: dari tombol tambah makanan di home ke halaman tambah makanan), muncul transisi putih yang mengganggu, terutama saat user membuka halaman secara cepat.  
**Solusi yang diterapkan:** Membuat `CustomPageRoute` dengan transisi fade yang smooth tanpa flash putih. Semua `MaterialPageRoute` telah diganti dengan `CustomPageRoute` di seluruh aplikasi. Custom route menggunakan `FadeTransition` dengan durasi 300ms dan background color transparan untuk menghindari flash putih.  
**Lokasi yang diperbaiki:** Semua file screen yang menggunakan navigasi (DashboardScreen, AddFoodScreen, AddActivityScreen, StatisticsScreen, ProfileScreen, SettingsScreen, dan semua file onboarding)

### ✅ Masalah 5: Menambahkan Permission Handling untuk Akses Galeri
**Status:** ✅ Selesai  
**Deskripsi:** Menambahkan izin dari user ketika aplikasi ingin mengakses galeri untuk memilih gambar. Permission hanya diminta saat pertama kali aplikasi mengakses galeri (on-demand).  
**Solusi yang diterapkan:** 
- Menambahkan package `permission_handler` untuk menangani permission secara runtime
- Menambahkan permission di AndroidManifest.xml (READ_EXTERNAL_STORAGE, READ_MEDIA_IMAGES, CAMERA)
- Menambahkan permission di iOS Info.plist (NSPhotoLibraryUsageDescription, NSCameraUsageDescription)
- Membuat `PermissionHelper` class dengan fungsi `requestGalleryPermission()` yang menampilkan dialog permission yang user-friendly
- Mengupdate fungsi `_pickImage()` di AddCustomFoodScreen dan ProfileScreen untuk request permission sebelum membuka galeri
- Menangani kasus permission ditolak permanen dengan dialog untuk membuka pengaturan aplikasi
**Lokasi yang diperbaiki:** 
- AddCustomFoodScreen - fungsi `_pickImage()`
- ProfileScreen - fungsi `_pickProfileImage()`
- lib/widgets/permission_helper.dart (file baru)

### ✅ Masalah 6: Membatasi Penambahan Riwayat Berat Badan Satu Kali Per Hari
**Status:** ✅ Selesai  
**Deskripsi:** User hanya bisa menambahkan riwayat berat badan sekali dalam sehari karena tidak mungkin user bisa menurunkan/menaikkan berat badan dalam sehari. Besoknya bisa diubah lagi, jadi batas waktunya sehari sekali untuk menambah riwayat berat badan.  
**Solusi yang diterapkan:** 
- Menambahkan fungsi `_hasWeightEntryForToday()` untuk mengecek apakah sudah ada entri berat badan untuk hari ini
- Memodifikasi fungsi `_addWeight()` untuk mengecek apakah sudah ada entri untuk hari ini sebelum menambahkan entri baru
- Menampilkan SnackBar dengan pesan yang jelas jika user mencoba menambah berat badan lagi di hari yang sama
- Validasi menggunakan perbandingan tanggal (year, month, day) untuk memastikan hanya satu entri per hari
**Lokasi yang diperbaiki:** 
- StatisticsScreen - fungsi `_addWeight()` dan fungsi helper `_hasWeightEntryForToday()`

### ✅ Masalah 7: Menambahkan Batasan Input Berat Badan
**Status:** ✅ Selesai  
**Deskripsi:** Aplikasi crash ketika user input berat badan 600 kg ke atas. Perlu menambahkan batasan input yang masuk akal untuk mencegah crash dan memastikan data yang valid.  
**Solusi yang diterapkan:** 
- Menambahkan validasi batasan berat badan: **minimal 20 kg dan maksimal 200 kg**
- Batasan ini mencakup rentang yang masuk akal untuk manusia (dari anak-anak hingga dewasa dengan obesitas ekstrem)
- Menambahkan validasi di semua tempat input berat badan:
  - AddWeightScreen: Validator di TextFormField dengan pesan error yang jelas
  - StatisticsScreen: Validasi di dialog edit berat badan dengan SnackBar error
  - InputWeightScreen: Update validator dari 1-600 kg menjadi 20-200 kg
  - EditProfileScreen: Validasi di fungsi _saveProfile sebelum menyimpan
- Menampilkan pesan error yang jelas dan informatif untuk setiap kasus (terlalu kecil/terlalu besar)
**Lokasi yang diperbaiki:** 
- AddWeightScreen - validator TextFormField
- StatisticsScreen - validasi di dialog edit berat badan
- InputWeightScreen - validator TextFormField
- EditProfileScreen - validasi di fungsi _saveProfile

### ✅ Masalah 8: Menambahkan Fitur Crop Gambar
**Status:** ✅ Selesai  
**Deskripsi:** Menambahkan fitur crop/edit gambar ketika user memilih foto untuk profil atau makanan tambahan, karena biasanya gambar kurang cocok jika langsung terpasang tanpa diposisikan.  
**Solusi yang diterapkan:** 
- Menambahkan package `image_cropper` untuk fitur crop gambar
- Menambahkan permission `WRITE_EXTERNAL_STORAGE` di AndroidManifest.xml untuk image_cropper
- Mengupdate fungsi `_pickImage()` di AddCustomFoodScreen untuk menampilkan crop dialog setelah memilih gambar dari galeri
- Mengupdate fungsi `_pickProfileImage()` di ProfileScreen untuk menampilkan crop dialog setelah memilih gambar dari galeri
- Menggunakan square crop (1:1) sebagai default, tapi user bisa mengubah aspect ratio sesuai kebutuhan
- UI crop disesuaikan dengan tema aplikasi (dark green background, light green text)
**Lokasi yang diperbaiki:** 
- AddCustomFoodScreen - fungsi `_pickImage()` dengan crop setelah memilih gambar
- ProfileScreen - fungsi `_pickProfileImage()` dengan crop setelah memilih gambar
- android/app/src/main/AndroidManifest.xml - permission WRITE_EXTERNAL_STORAGE

### ✅ Masalah 9: Force Close Saat Memilih Foto dari Galeri
**Status:** ✅ Selesai  
**Deskripsi:** Aplikasi force close ketika user memilih foto dari galeri. Masalah terjadi karena ImageCropper crash saat dipanggil, kemungkinan karena konfigurasi Android yang kurang atau masalah dengan FileProvider.  
**Solusi yang diterapkan:** 
- **Menonaktifkan crop sementara** untuk menghindari crash - aplikasi sekarang langsung menggunakan gambar asli tanpa crop
- Menyederhanakan proses pemilihan gambar: pick image → save langsung tanpa crop
- Menambahkan error handling yang lebih baik untuk operasi file copy
- Menampilkan pesan error yang informatif jika terjadi masalah saat menyimpan gambar
- **Catatan:** Fitur crop bisa diaktifkan kembali nanti setelah konfigurasi Android (FileProvider) diperbaiki
**Lokasi yang diperbaiki:** 
- AddCustomFoodScreen - fungsi `_pickImage()` dengan crop dinonaktifkan sementara
- ProfileScreen - fungsi `_pickProfileImage()` dengan crop dinonaktifkan sementara

### ✅ Masalah 10: Validasi Kalori dan Indikator Warna Merah untuk Kalori Masuk
**Status:** ✅ Selesai  
**Deskripsi:** 
1. Kalori yang masuk tidak boleh minus - perlu batas minimal 0
2. Jika kalori melewati batas kalori harian user, lingkaran dan teks harus menjadi merah seperti kalori harian di home
3. Protein, lemak, dan karbohidrat juga tidak boleh minus - perlu proteksi yang sama seperti kalori
**Solusi yang diterapkan:** 
- **Validasi kalori di AddCustomFoodScreen:**
  - Memperbaiki validator untuk memastikan kalori >= 0 (tidak boleh minus)
  - Pesan error yang jelas: "Kalori tidak boleh minus (minimal 0)"
  - Validasi juga memastikan kalori > 0 (tidak boleh 0)
- **Validasi macronutrients di AddCustomFoodScreen:**
  - Menambahkan validasi untuk protein, lemak, dan karbohidrat dengan batas minimal 0
  - Pesan error yang jelas: "Protein/Lemak/Karbohidrat tidak boleh minus (minimal 0)"
  - Validasi hanya berlaku jika field tidak kosong (karena opsional)
- **Perhitungan kalori dan macronutrients yang aman:**
  - Memastikan kalori yang dihitung di DashboardScreen tidak bisa minus (menggunakan max(0, calories)) di 3 tempat
  - Memastikan protein, lemak, dan karbohidrat yang dihitung di DashboardScreen tidak bisa minus (menggunakan max(0, value)) di 3 tempat
  - Memastikan kalori dan macronutrients yang dihitung di FoodDetailScreen tidak bisa minus
- **Indikator warna merah untuk macronutrients:**
  - Memodifikasi fungsi `_buildMacronutrientCircle()` untuk menampilkan warna merah jika melewati batas
  - Menggunakan warna merah yang sama dengan kalori harian (Color(0xFFB22222))
  - Warna merah diterapkan pada lingkaran progress, teks nilai, dan label
  - Logika: jika current > total dan total > 0, maka tampilkan warna merah
**Lokasi yang diperbaiki:** 
- AddCustomFoodScreen - validator kalori, protein, lemak, dan karbohidrat dengan batas minimal 0
- DashboardScreen - perhitungan kalori dan macronutrients yang aman (3 tempat) dan fungsi `_buildMacronutrientCircle()` dengan indikator merah
- FoodDetailScreen - perhitungan kalori dan macronutrients yang aman di `_calculateAdjustedFood()`

### ✅ Masalah 11: Label Tanggal di Grafik Statistik Berat Badan Tidak Update
**Status:** ✅ Selesai  
**Deskripsi:** Label tanggal di bagian bawah grafik statistik berat badan tidak update ketika user menambahkan riwayat berat badan baru. Masalah terjadi karena kondisi pengecekan menggunakan `widget.weightEntries.length` padahal seharusnya menggunakan `sortedEntries.length`.  
**Solusi yang diterapkan:** 
- Memperbaiki kondisi pengecekan di `getTitlesWidget` untuk menggunakan `sortedEntries.length` yang benar
- Menambahkan validasi index yang lebih baik (`index >= 0 && index < sortedEntries.length`)
- Memperbaiki format tanggal:
  - Format default: `DD/MM` (contoh: 26/11, 27/11)
  - Jika data dari tahun yang berbeda, format menjadi: `DD/MM/YY` (contoh: 26/11/24, 27/11/25)
  - Format otomatis menyesuaikan berdasarkan data yang ada
- Menambahkan `interval: 1` untuk memastikan setiap titik data ditampilkan labelnya
- Meningkatkan `reservedSize` dari 30 ke 35 untuk memberikan ruang lebih untuk label tanggal
**Rekomendasi format tanggal:**
- Format `DD/MM` untuk data dalam tahun yang sama (lebih ringkas)
- Format `DD/MM/YY` untuk data lintas tahun (lebih informatif)
- Format ini mudah dibaca dan tidak terlalu panjang
**Lokasi yang diperbaiki:** 
- StatisticsScreen - fungsi `getTitlesWidget` di `bottomTitles` untuk label x-axis

### ✅ Fitur Baru: Edit Makanan yang Sudah Ditambahkan
**Status:** ✅ Selesai  
**Deskripsi:** Menambahkan fitur untuk mengedit makanan yang sudah ditambahkan di halaman home. User dapat menekan menu makanan yang sudah ditambahkan untuk masuk ke halaman edit (mirip dengan halaman tambah makanan) dengan tombol "Simpan" sebagai ganti "Tambahkan Makanan". Foto makanan yang sudah ada (baik dari makanan default aplikasi maupun makanan tambahan user) ditampilkan dan tidak dapat diubah di halaman edit.  
**Solusi yang diterapkan:** 
- **Modifikasi AddCustomFoodScreen untuk mode edit:**
  - Menambahkan parameter optional `FoodEntry? existingFood` dan `bool isEditMode` untuk mendukung mode edit
  - Mengisi field-field form dengan data existingFood saat mode edit diaktifkan
  - Mengubah title AppBar menjadi "Edit Makanan" saat mode edit
  - Mengubah teks tombol dari "Tambahkan Makanan" menjadi "Simpan" saat mode edit
  - Memanggil callback `onFoodAdded` dengan data yang sudah diisi saat tombol "Simpan" ditekan
- **Menampilkan foto makanan yang sudah ada:**
  - Menambahkan variabel `_existingImagePath` untuk menyimpan path gambar yang sudah ada (bisa asset atau file)
  - Membuat fungsi `_buildImage()` untuk menampilkan gambar dari asset (`Image.asset`) atau file (`Image.file`)
  - Menampilkan foto yang sudah ada dengan benar baik untuk makanan default (asset) maupun makanan tambahan user (file)
  - Menggunakan path gambar yang sudah ada saat simpan jika tidak ada gambar baru yang dipilih
- **Menonaktifkan perubahan foto di mode edit:**
  - Menonaktifkan `GestureDetector` onTap di mode edit (`onTap: widget.isEditMode ? null : _pickImage`)
  - Mengubah label foto menjadi "Foto Makanan (Tidak Dapat Diubah)" di mode edit
  - Foto hanya bisa diubah saat menambah makanan baru, tidak saat edit
- **Menambahkan fungsi _updateFood() di DashboardScreen:**
  - Fungsi untuk mengupdate makanan yang sudah ada di list `_foodEntries`
  - Menghitung ulang kalori dan macronutrients yang dikonsumsi setelah update
  - Menyimpan perubahan ke SharedPreferences
- **Menambahkan navigasi ke halaman edit:**
  - Menambahkan `InkWell` pada item makanan di `_buildFoodEntriesList()` untuk menangani tap
  - Mencari index makanan di `_foodEntries` (bukan di groupedEntries) untuk update yang akurat
  - Navigasi ke `AddCustomFoodScreen` dengan mode edit dan callback untuk update makanan
  - Reload entries setelah edit selesai untuk memastikan data terbaru ditampilkan
- **Mencegah multiple navigation:**
  - Menggunakan flag `_isNavigating` untuk mencegah multiple navigation saat edit
**Lokasi yang diperbaiki:** 
- AddCustomFoodScreen - parameter `existingFood` dan `isEditMode`, logika initState untuk mengisi field, fungsi `_buildImage()` untuk menampilkan gambar, menonaktifkan onTap di mode edit, dan perubahan title/tombol
- DashboardScreen - fungsi `_updateFood()`, import `AddCustomFoodScreen`, dan modifikasi `_buildFoodEntriesList()` dengan `InkWell` untuk navigasi edit

### ✅ Masalah 13: Layout Terpotong di Beberapa Device (Realme 5 Pro)
**Status:** ✅ Selesai  
**Deskripsi:** Di beberapa device seperti Realme 5 Pro, halaman home (Dashboard) terpotong dan tidak menyesuaikan ukuran layar dengan baik. Layout tidak responsif untuk berbagai ukuran layar.  
**Solusi yang diterapkan:** 
- **Menambahkan SafeArea:**
  - Membungkus `SingleChildScrollView` dengan `SafeArea` untuk menangani system UI (notch, status bar, dll)
  - Menambahkan padding bottom yang mempertimbangkan system navigation bar
- **Membuat layout responsif dengan LayoutBuilder:**
  - Menggunakan `LayoutBuilder` dan `MediaQuery` untuk mendapatkan ukuran layar
  - Ukuran circular progress indicator sekarang responsif: `(screenWidth * 0.5).clamp(150.0, 220.0)`
  - Font size untuk angka kalori responsif: `(circleSize * 0.22).clamp(32.0, 48.0)`
  - Font size untuk label responsif: `(circleSize * 0.07).clamp(12.0, 16.0)`
  - Font size untuk side text (Masuk/Dibakar) responsif: `(circleSize * 0.11).clamp(18.0, 24.0)`
  - Stroke width untuk CircularProgressIndicator responsif: `(circleSize * 0.055).clamp(8.0, 12.0)`
  - Border width responsif: `(circleSize * 0.027).clamp(4.0, 6.0)`
- **Menggunakan FittedBox untuk teks:**
  - Membungkus teks angka kalori dan label dengan `FittedBox` untuk memastikan teks tidak overflow
  - Menggunakan `Flexible` widget untuk kolom "Masuk" dan "Dibakar" agar bisa menyesuaikan ukuran
- **Spacing responsif:**
  - Menggunakan `screenWidth * 0.05` untuk spacing antara elemen, bukan fixed width
- **Padding responsif:**
  - Padding bottom menyesuaikan dengan tinggi system navigation bar menggunakan `MediaQuery.of(context).padding.bottom`
**Lokasi yang diperbaiki:** 
- DashboardScreen - menambahkan SafeArea, LayoutBuilder untuk circular progress indicator, dan membuat semua ukuran responsif berdasarkan lebar layar

---

## Catatan
- ✅ = Masalah sudah diatasi
- 🔄 = Sedang dikerjakan
- ⏳ = Menunggu
- ❌ = Masalah belum diatasi

