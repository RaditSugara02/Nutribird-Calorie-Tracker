# Alur Aplikasi Calorie Tracker

Berikut adalah alur aplikasi yang telah ditentukan:

**Aturan Folder Desain:**
*   `lib/designs/BackgroundDesign/`: Berisi gambar latar belakang saja (misalnya, `BGWelcome_Screen.png`, `BGWelcome_Screen2.png`).
*   `lib/designs/`: Berisi desain jadi dalam format JPG/PNG yang sudah mencakup elemen UI lain seperti tombol, dll. (misalnya, `Welcome_Screen.jpg`, `Welcome_Screen2.jpg`).

1.  **Welcome Screen 1 (`welcomescreen_1`)**
    *   **STATUS: Selesai diimplementasikan dengan desain yang diberikan.**
    *   Menampilkan tombol "Lanjutkan".
    *   Tombol "Lanjutkan" mengarahkan ke `welcomescreen_2`.

2.  **Welcome Screen 2 (`welcomescreen_2`)**
    *   **STATUS: Selesai diimplementasikan dengan desain dan warna tombol yang diberikan.**
    *   Menampilkan dua tombol: "Daftar" dan "Masuk".
    *   **Warna Tombol (Daftar):** Background A2F46E, Teks 112D21.
    *   **Warna Tombol (Masuk):** Background 1D362C, Teks A2F46E.
    *   **Sistem Login Lokal**: Akan menggunakan Hive sebagai database untuk data login dan makanan.
    *   **Jika "Masuk" dipilih**: Pengguna akan diminta untuk menginput email dan kata sandi yang sudah terdaftar untuk masuk ke halaman dashboard/home.
    *   **Jika "Daftar" dipilih**: Pengguna akan diarahkan ke halaman registrasi.

    **Analisis Navigasi Tombol "Lanjutkan" (diperbarui):**
    *   **`welcomescreen_2.dart` (Tombol "Masuk")**
        *   Menavigasi ke: `loginscreen.dart`
        *   **Status: BENAR.**

3.  **Halaman Registrasi**
    *   **STATUS: Selesai diimplementasikan dengan input email, kata sandi, dan konfirmasi kata sandi, serta navigasi ke halaman input nama. Desain telah disesuaikan dengan *screenshot* yang diberikan. Validasi input telah ditambahkan. **Fungsionalitas hide/show password telah diimplementasikan.**
    *   Pengguna diminta untuk menginput email, kata sandi, dan kata sandi konfirmasi.
    *   Setelah mengisi, menekan tombol "Lanjutkan".
    *   Diarahkan ke halaman input nama.

    **Detail Validasi Input:**
    *   **Email:** Tidak boleh kosong dan harus dalam format email yang valid.
    *   **Kata Sandi:** Tidak boleh kosong dan minimal 6 karakter.
    *   **Konfirmasi Kata Sandi:** Tidak boleh kosong dan harus cocok dengan Kata Sandi.

**Halaman Login (`loginscreen.dart`)**
*   **STATUS: Selesai didesain ulang, validasi input telah ditambahkan untuk email dan kata sandi, dan **fungsionalitas hide/show password telah diimplementasikan.**
*   Pengguna menginput email dan kata sandi.
*   Menekan tombol "Lanjutkan".
*   Diarahkan ke halaman dashboard/home.

    **Detail Validasi Input:**
    *   **Email:** Tidak boleh kosong dan harus dalam format email yang valid.
    *   **Kata Sandi:** Tidak boleh kosong dan minimal 6 karakter.

4.  **Halaman Input Nama**
    *   **STATUS: Selesai diimplementasikan dengan input nama dan navigasi ke halaman pilihan gender. Desain telah disesuaikan dengan *screenshot* `Onboarding_1_nama.png`. Validasi input telah ditambahkan. **Progress bar (1/7) telah diimplementasikan.**
    *   Pengguna menginput nama mereka.
    *   Menekan tombol "Lanjutkan".
    *   Diarahkan ke halaman pilihan gender.

5.  **Halaman Pilihan Gender**
    *   **STATUS: Selesai diimplementasikan dengan opsi pilihan gender dan navigasi ke halaman pilihan tahun lahir. Desain telah disesuaikan dengan *screenshot* `Onboarding_2_gender.png`. Validasi pilihan telah ditambahkan. **Progress bar (2/7) telah diimplementasikan.**
    *   Pengguna memilih gender mereka.
    *   Diarahkan ke halaman pilihan tahun lahir.

6.  **Halaman Pilih Tahun Lahir**
    *   **STATUS: Selesai diimplementasikan dengan opsi pilihan tahun lahir dan navigasi ke halaman input tinggi badan. Desain telah disesuaikan dengan *screenshot* `Onboarding_3_lahir.png` dan tampilan input tanggal lahir telah dirombak menjadi pemilih bergulir. Validasi pilihan telah ditambahkan. Progress bar (3/7) telah diimplementasikan.**
    *   Pengguna memilih tahun lahir mereka.
    *   **Validasi Usia**: Memastikan usia pengguna berada dalam rentang 15 hingga 80 tahun, sesuai batasan kalkulator kalori dari `calculator.net`.
    *   Diarahkan ke halaman input tinggi badan.

    - Meneruskan `name`, `gender`, `birthDay`, `birthMonth`, dan `birthYear` ke `InputHeightScreen`.

7.  **Halaman Input Tinggi Badan**
    *   **STATUS: Selesai diimplementasikan dengan input tinggi badan dan navigasi ke halaman input berat badan. Desain telah disesuaikan dengan *screenshot* `Onboarding_4_TinggiBadan.png`. Validasi input telah ditambahkan. **Progress bar (4/7) telah diimplementasikan.**
    *   Pengguna menginput tinggi badan mereka.
    *   **Validasi Tinggi Badan**: Memastikan tinggi badan antara 50 cm dan 250 cm.
    *   Diarahkan ke halaman input berat badan.

8.  **Halaman Input Berat Badan**
    *   **STATUS: Selesai diimplementasikan dengan input berat badan dan navigasi ke halaman input tingkat aktivitas. Desain telah disesuaikan dengan *screenshot* `Onboarding_5_BeratBadan.png`. Validasi input telah ditambahkan. **Progress bar (5/7) telah diimplementasikan.**
    *   Pengguna menginput berat badan mereka.
    *   **Validasi Berat Badan**: Memastikan berat badan antara 1 kg dan 600 kg.
    *   Diarahkan ke halaman input tingkat aktivitas.

9.  **Halaman Input Tingkat Aktivitas User**
    *   **STATUS: Selesai diimplementasikan dengan opsi pilihan tingkat aktivitas dan navigasi ke halaman input goal user. Desain telah disesuaikan dengan *screenshot* `Onboarding_6_Aktif.png`. Validasi pilihan telah ditambahkan. **Progress bar (6/7) telah diimplementasikan.**
    *   Pengguna menginput tingkat aktivitas mereka.
    *   Diarahkan ke halaman input goal user.

10. **Halaman Input Goal User**
    *   **STATUS: Selesai diimplementasikan dengan input goal dan navigasi ke halaman loading. Desain telah disesuaikan dengan *screenshot* `Onboarding_7_Goal.png`. Validasi pilihan telah ditambahkan. **Progress bar (7/7) telah diimplementasikan.**
    *   Pengguna menginput goal mereka.
    *   Menekan tombol "Lanjutkan".
    *   Diarahkan ke halaman loading.

11. **Halaman Loading (0%-100%)**
    *   **STATUS: Selesai diimplementasikan dengan indikator loading dan navigasi otomatis ke halaman overview hasil user. Desain telah disesuaikan dengan *screenshot* `Onboarding_8_LoadingScreen.png`.**
    *   Menampilkan progres loading.
    *   Setelah 100%, pengguna otomatis diarahkan ke halaman overview hasil user.

    ### Penambahan Persentase di `LoadingScreen.dart`

    - **Status:** Diimplementasikan
    - **Detail:** Halaman loading kini menampilkan indikator persentase dari 0% hingga 100% menggunakan `Timer` untuk memperbarui progres secara bertahap. Ini meningkatkan pengalaman pengguna dengan memberikan visualisasi kemajuan.

12. **Halaman Overview Hasil User**
    *   **STATUS: Selesai diimplementasikan dan didesain ulang sesuai *screenshot* yang diberikan.**
    *   Menampilkan informasi penting pengguna seperti kebutuhan kalori harian, BMI, dan estimasi makronutrien (karbohidrat, lemak, protein).
    *   Menampilkan ringkasan data input pengguna (tujuan, usia, berat badan, tinggi badan) dalam format yang lebih terstruktur.
    *   **Perhitungan BMI**: `berat (kg) / (tinggi (m) * tinggi (m))` telah diimplementasikan.
    *   **Perhitungan Makronutrien**: Estimasi karbohidrat, lemak, dan protein (berdasarkan rasio umum 50:30:20) telah ditambahkan.
    *   Tetap menampilkan catatan: `*Catatan: Ini adalah estimasi. Konsultasikan dengan ahli gizi untuk rencana yang lebih personal.`
    *   Menampilkan tombol "Lanjutkan".
    *   Tombol "Lanjutkan" mengarahkan ke halaman dashboard.

*(Catatan: Halaman dashboard akan diskip untuk saat ini, fokus pada implementasi alur di atas.)*

## Analisis Navigasi Tombol "Lanjutkan"

Berikut adalah alur navigasi halaman dan status tombol "Lanjutkan" di setiap halaman:

*   **`welcomescreen_1.dart` (Tombol "Lanjutkan")**
    *   Menavigasi ke: `welcomescreen_2.dart`
    *   **Status: BENAR.**

*   **`welcomescreen_2.dart`**
    *   **Tombol "Daftar"**
        *   Menavigasi ke: `registrationscreen.dart`
        *   **Status: BENAR.**
    *   **Tombol "Masuk"**
        *   Menavigasi ke: `loginscreen.dart`
        *   **Status: BENAR.**

*   **`registrationscreen.dart` (Tombol "Lanjutkan")**
    *   Menavigasi ke: `inputnamescreen.dart`
    *   **Status: BENAR.**

*   **`inputnamescreen.dart` (Tombol "Lanjutkan")**
    *   Menavigasi ke: `selectgenderscreen.dart`
    *   **Status: BENAR.**

*   **`selectgenderscreen.dart` (Tombol "Lanjutkan")**
    *   Menavigasi ke: `selectbirthyearscreen.dart`
    *   **Status: BENAR.**

*   **`selectbirthyearscreen.dart` (Tombol "Lanjutkan")**
    *   Menavigasi ke: `inputheightscreen.dart`
    *   **Status: BENAR.**

*   **`inputheightscreen.dart` (Tombol "Lanjutkan")**
    *   Menavigasi ke: `inputweightscreen.dart`
    *   **Status: BENAR.**

*   **`inputweightscreen.dart` (Tombol "Lanjutkan")**
    *   Menavigasi ke: `inputactivitylevelscreen.dart`
    *   **Status: BENAR.**

*   **`inputactivitylevelscreen.dart` (Tombol "Lanjutkan")**
    *   Menavigasi ke: `inputgoalscreen.dart`
    *   **Status: BENAR.**

*   **`inputgoalscreen.dart` (Tombol "Lanjutkan")**
    *   Menavigasi ke: `loadingscreen.dart`
    *   **Status: BENAR.**

*   **`loadingscreen.dart` (Navigasi Otomatis setelah loading)**
    *   Menavigasi ke: `overviewresultscreen.dart`
    *   **Status: BENAR.**

*   **`overviewresultscreen.dart` (Tombol "Lanjutkan")**
    *   Menavigasi ke: `dashboardscreen.dart`
    *   **Status: BENAR.**

## Perbaikan Masalah *text overflow* pada `inputgoalscreen.dart`

- `Menambah Berat Badan`
- Validasi: Pengguna harus memilih tujuan.
- **Perbaikan**: Masalah *text overflow* pada opsi tujuan yang panjang telah diperbaiki dengan menggunakan `Expanded` widget pada teks tujuan.
- Meneruskan semua data input pengguna dan `goal` ke `LoadingScreen`.

## 6. Loading Screen (`loadingscreen.dart`)
- **Deskripsi**: Layar loading saat aplikasi menghitung hasil kalori.
- **Implementasi**: 
  - Warna latar belakang dan indikator loading disesuaikan dengan tema gelap.
  - Menerima semua data input pengguna dari `InputGoalScreen` dan meneruskannya ke `OverviewResultScreen` setelah simulasi loading 3 detik.

### Validasi Perhitungan BMI

- **Status:** Tervalidasi
- **Detail:** Perhitungan BMI di `overviewresultscreen.dart` menggunakan rumus standar metrik (`berat (kg) / tinggi (m)^2`) yang sesuai dengan informasi dari `calculator.net/bmi-calculator.html`. Tinggi badan dari cm dikonversi ke meter sebelum perhitungan. 

### Perbaikan Tampilan `OverviewResultScreen.dart`

- **Status:** Diimplementasikan
- **Detail:** Mengatasi masalah *text overflow* pada tampilan nilai 'Tujuan' di bagian ringkasan hasil. `Text` yang menampilkan nilai tujuan kini dibungkus dengan widget `Expanded` dan menggunakan `TextOverflow.ellipsis` dengan `maxLines: 2` untuk penanganan teks panjang agar tidak melewati batas. 

### Implementasi `DashboardScreen.dart`

- **Status:** Diimplementasikan dan Didesain
- **Detail:**
  - Halaman `DashboardScreen` diubah menjadi `StatefulWidget`.
  - Menampilkan `AppBar` kustom dengan tanggal saat ini, tombol kembali dan maju.
  - Menampilkan ringkasan kalori harian (`dailyCalories`), serta informasi kalori 'Masuk' dan 'Dibakar' dengan visualisasi lingkaran progres.
  - Menampilkan target makronutrien (Karbohidrat, Lemak, Protein) dengan lingkaran progres masing-masing.
  - Menerima `dailyCalories`, `proteinGrams`, `fatGrams`, dan `carbGrams` dari `OverviewResultScreen` melalui konstruktor.
  - Menambahkan `Card` untuk aksi "Tambah Makanan" dengan ikon yang relevan.
  - Mengimplementasikan `BottomNavigationBar` dengan tiga ikon: Home, Statistik Berat Badan, dan Profil.

### Penyesuaian Navigasi `DashboardScreen.dart`

- **Status:** Diimplementasikan
- **Detail:** Tombol kembali (`leading: IconButton`) dari `AppBar` di `DashboardScreen.dart` telah dihapus. Ini memastikan pengguna tidak dapat langsung kembali ke `OverviewResultScreen.dart` atau halaman sebelumnya, sesuai dengan alur aplikasi yang diinginkan (opsi untuk mengubah data akan ada di halaman profil).

### Perbaikan Navigasi dari `OverviewResultScreen.dart` ke `DashboardScreen.dart`

- **Status:** Diperbaiki
- **Detail:** Navigasi dari `OverviewResultScreen` ke `DashboardScreen` diubah dari `Navigator.push` menjadi `Navigator.pushReplacement`. Ini memastikan `OverviewResultScreen` dikeluarkan dari tumpukan navigasi, sehingga pengguna tidak dapat kembali ke halaman hasil setelah melanjutkan ke dashboard.

### Penghapusan Tombol Kembali Implisit di `DashboardScreen.dart`

- **Status:** Diimplementasikan
- **Detail:** Properti `automaticallyImplyLeading: false` ditambahkan pada `AppBar` di `DashboardScreen.dart`. Ini secara eksplisit menonaktifkan tombol kembali yang secara otomatis ditambahkan oleh Flutter jika ada rute sebelumnya di tumpukan navigasi, memastikan pengguna tidak dapat kembali ke halaman hasil dari dashboard.

### Perbaikan Navigasi dari `LoginScreen.dart`

- **Status:** Diperbaiki
- **Detail:** Navigasi dari `LoginScreen` ke `DashboardScreen` diperbaiki dengan meneruskan nilai `dailyCalories`, `proteinGrams`, `fatGrams`, dan `carbGrams` sebagai `0` (nilai *default*) ke konstruktor `DashboardScreen`. Ini mengatasi *error* yang muncul karena `DashboardScreen` kini memerlukan parameter tersebut.

### Peningkatan Fungsionalitas `DashboardScreen.dart`

- **Status:** Diimplementasikan
- **Detail:**
  - **Navigasi Tanggal**: Menambahkan fungsionalitas navigasi tanggal (`_currentDate`, `_goToPreviousDay()`, `_goToNextDay()`) di `AppBar`, memungkinkan pengguna untuk melihat data harian dari tanggal yang berbeda.
  - **Integrasi Tab Navigasi Bawah**: Menggunakan `IndexedStack` di `body` `DashboardScreen` untuk mengelola tiga tab: Home (default), Statistik Berat Badan, dan Profil Pengguna. Ini memungkinkan perpindahan mulus antar tab tanpa kehilangan `state`.
  - **Halaman Placeholder**: Membuat `lib/screens/statisticsscreen.dart` dan `lib/screens/profilescreen.dart` sebagai halaman *placeholder* awal untuk tab Statistik dan Profil.

### Perombakan Desain dan Fungsionalitas `DashboardScreen.dart` (Home Tab)

- **Status:** Diimplementasikan
- **Detail:**
  - **`AppBar` Sederhana**: `AppBar` hanya menampilkan judul "Dashboard" tanpa elemen tanggal atau navigasi hari.
  - **Navigasi Tanggal Dipindahkan**: Fungsionalitas tampilan tanggal dan tombol panah navigasi hari (maju/mundur) telah dipindahkan ke dalam konten tab 'Home' (di dalam `SingleChildScrollView`).
  - **Lingkaran Kalori Utama Disesuaikan**: Hanya sisa kalori harian (`_remainingCalories`) yang ditampilkan di dalam lingkaran. Informasi 'Masuk' (`_caloriesConsumed`) dan 'Dibakar' (`_caloriesBurned`) ditempatkan di luar lingkaran, di sisi kiri dan kanan.
  - **Progres Lingkaran Dinamis**: Lingkaran utama kini berfungsi sebagai *progress bar* yang memvisualisasikan sisa kalori harian (`_calorieProgress`), memberikan indikasi visual yang jelas tentang penggunaan kalori.
  - **Simulasi Penambahan Kalori**: Menambahkan fungsi `_addFoodCalories()` yang dipicu oleh tombol 'Tambah Makanan', memperbarui `_caloriesConsumed` dan secara otomatis mempengaruhi `_remainingCalories` serta progres lingkaran. 

### Implementasi Penyimpanan Detail Makanan dan Aktivitas di `DashboardScreen.dart`

- **Status:** Diimplementasikan
- **Detail:**
  - **Struktur Data Baru**: Mendefinisikan kelas `FoodEntry` (nama makanan, kalori, jenis makanan) dan `ActivityEntry` (nama aktivitas, kalori dibakar) untuk penyimpanan data yang lebih terperinci.
  - **Penyimpanan/Pemuatan Lanjutan**: Fungsi `_loadEntriesAndCalculateCalories()` dan `_saveEntries()` dimodifikasi untuk memuat dan menyimpan daftar objek `FoodEntry` dan `ActivityEntry` dari/ke `shared_preferences` menggunakan serialisasi JSON.
  - **Kalkulasi Kalori Dinamis**: `_caloriesConsumed` sekarang dihitung berdasarkan total kalori dari `_foodEntries`, dan `_caloriesBurned` dari `_activityEntries`.
  - **Integrasi Input Aktivitas**: Menambahkan tombol 'Tambah Aktivitas' yang menavigasi ke `AddActivityScreen` dan menggunakan callback `_addActivity` untuk memperbarui data kalori yang dibakar.
  - **Tampilan Daftar Makanan**: Menambahkan bagian UI di tab Home untuk menampilkan daftar makanan yang dikonsumsi, dikelompokkan berdasarkan jenis makanan.

### Peningkatan Fungsionalitas Statistik Berat Badan di `StatisticsScreen.dart`

- **Status:** Diimplementasikan
- **Detail:**
  - **Pembaruan Grafik Otomatis**: Memastikan `StatisticsScreen` menerima pembaruan data `weightEntries` dari `DashboardScreen` dan memperbarui grafik berat badan secara otomatis.
  - **Penanganan Grafik Satu Titik Data**: Menyesuaikan perhitungan `maxX` pada `LineChartData` untuk memastikan grafik ditampilkan dengan benar bahkan jika hanya ada satu entri berat badan. Jika `spots.length <= 1`, `maxX` diatur ke `1.0` untuk memberikan rentang visual yang valid.
  - **Debugging Logging**: Menambahkan log di metode `didUpdateWidget` untuk memverifikasi kapan properti `weightEntries` diperbarui, membantu diagnosis aliran data.

### Implementasi Pencatatan Berat Badan di `AddWeightScreen.dart` dan `DashboardScreen.dart`

- **Status:** Diimplementasikan
- **Detail:**
  - **Halaman Input Berat Badan**: Membuat `AddWeightScreen.dart` sebagai halaman terpisah untuk pengguna memasukkan berat badan mereka, lengkap dengan validasi input.
  - **Struktur Data Berat Badan**: Mendefinisikan kelas `WeightEntry` (berat badan, tanggal) untuk menyimpan entri berat badan.
  - **Penyimpanan/Pemuatan Berat Badan**: Memperbarui fungsi `_loadEntriesAndCalculateCalories()` dan `_saveEntries()` di `DashboardScreen.dart` untuk memuat dan menyimpan daftar objek `WeightEntry` ke `shared_preferences`.
  - **Integrasi Tombol**: Menambahkan tombol 'Catat Berat Badan' di `DashboardScreen.dart` yang menavigasi ke `AddWeightScreen` dan menggunakan callback `_addWeight` untuk memperbarui data berat badan.

### Implementasi Tampilan Grafik dan Riwayat Berat Badan di `StatisticsScreen.dart`

- **Status:** Diimplementasikan
- **Detail:**
  - **Perubahan ke StatefulWidget**: Mengubah `StatisticsScreen` menjadi `StatefulWidget` untuk mengelola state data berat badan.
  - **Pemuatan Data Berat Badan**: Mengimplementasikan `_loadWeightEntries()` untuk memuat riwayat berat badan dari `shared_preferences`.
  - **Visualisasi Grafik**: Mengintegrasikan `fl_chart` untuk menampilkan riwayat berat badan dalam bentuk grafik garis yang interaktif, dengan sumbu X (tanggal) dan Y (berat badan).
  - **Tampilan Daftar Riwayat**: Mempertahankan tampilan daftar riwayat berat badan di bawah grafik untuk referensi detail.

### Implementasi Penyimpanan dan Tampilan Data Profil Pengguna di `OverviewResultScreen.dart` dan `ProfileScreen.dart`

- **Status:** Diimplementasikan
- **Detail:**
  - **Penyimpanan Profil di `OverviewResultScreen.dart`**: Menambahkan fungsi `_saveUserProfile()` yang menyimpan semua data input pengguna (nama, gender, tahun lahir, tinggi, berat, tingkat aktivitas, tujuan, kalori harian, dan makronutrien) ke `shared_preferences` sebagai string JSON sebelum navigasi ke `DashboardScreen`.
  - **Pemuatan dan Tampilan Profil di `ProfileScreen.dart`**: Mengubah `ProfileScreen` menjadi `StatefulWidget` yang memuat data profil dari `shared_preferences` dan menampilkannya secara terorganisir, termasuk informasi pribadi dan rencana kalori & makro. 

### Peningkatan Fungsionalitas Manajemen Makanan

- **Status:** Diimplementasikan
- **Detail:**
  - **Pembaruan Struktur Data Makanan (`FoodEntry` di `dashboardscreen.dart`)**:
    - Menambahkan properti opsional `protein` (gram), `fat` (gram), dan `carb` (gram) ke kelas `FoodEntry`.
    - Metode `toJson` dan `fromJson` diperbarui untuk mengakomodasi properti baru ini.
  - **Modifikasi `AddFoodScreen.dart` (Halaman Pilih Makanan)**:
    - Menambahkan `TextFormField` sebagai `search bar` untuk memfilter daftar makanan berdasarkan nama.
    - Mengimplementasikan `_loadAllFoods()` untuk memuat makanan pradefinisi bawaan dan makanan kustom yang disimpan pengguna dari `SharedPreferences`.
    - Mengimplementasikan `_saveUserFoods()` untuk menyimpan makanan kustom yang ditambahkan pengguna ke `SharedPreferences`.
    - Menambahkan ikon `add` (+) di `AppBar` yang menavigasi ke `AddCustomFoodScreen`.
    - Menampilkan daftar makanan yang difilter, termasuk makanan pradefinisi dan yang ditambahkan pengguna, dalam `ListView.builder`.
    - Mengubah `onTap` pada setiap item makanan untuk mengirimkan data `FoodEntry` lengkap (termasuk makronutrien) kembali ke `DashboardScreen`.
  - **Pembuatan Halaman Baru `AddCustomFoodScreen.dart`**:
    - Membuat halaman terpisah untuk memungkinkan pengguna menambahkan makanan kustom mereka sendiri.
    - Formulir input di halaman ini mencakup nama makanan, jumlah kalori (wajib), serta protein, lemak, dan karbohidrat (opsional).
    - Setelah penambahan, halaman ini mengembalikan objek `FoodEntry` lengkap ke `AddFoodScreen`.
  - **Penyesuaian Fungsi `_addFood` di `DashboardScreen.dart`**:
    - Fungsi `_addFood` sekarang menerima `protein`, `fat`, dan `carb` sebagai parameter opsional.
    - Parameter ini diteruskan saat membuat objek `FoodEntry` baru, memastikan data makronutrien lengkap disimpan. 