# 📖 Panduan Lengkap: Input Makanan Custom

## 🎯 Ringkasan Fitur

Fitur **Tambah Makanan Kustom** memungkinkan Anda menambahkan makanan dengan estimasi macro otomatis berdasarkan nama makanan dan kalori. Sistem akan:
- ✅ Auto-detect kategori makanan dari nama
- ✅ Auto-generate estimasi protein, lemak, dan karbohidrat
- ✅ Validasi real-time untuk memastikan data konsisten
- ✅ Memberikan peringatan jika input tidak realistis

---

## 📝 Cara Menggunakan

### **Langkah 1: Input Nama Makanan**
- Ketik nama makanan di field **"Nama Makanan"**
- Contoh: `Nasi Goreng`, `Ayam Bakar`, `Salad Sayur`
- **Tips**: Gunakan nama yang jelas dan spesifik

### **Langkah 2: Pilih Jenis Makanan**
- Pilih dari dropdown: `Sarapan`, `Makan Siang`, `Makan Malam`, atau `Cemilan`
- **Wajib diisi**

### **Langkah 3: Input Jumlah Kalori**
- Ketik jumlah kalori dalam satuan **kcal**
- Contoh: `350`, `500`, `200`
- **Wajib diisi** dan harus **> 0**

### **Langkah 4: Sistem Auto-Generate Macro**
Setelah Anda input nama dan kalori, sistem akan:
1. **Detect kategori** dari nama makanan
2. **Generate estimasi** protein, lemak, dan karbohidrat
3. **Auto-fill** field macro (jika checkbox "Sudah sesuai?" checked)

### **Langkah 5: Review atau Edit Macro (Opsional)**
- Jika estimasi sudah sesuai → **Centang "Sudah sesuai?"** → Langsung simpan
- Jika perlu edit → **Uncheck "Sudah sesuai?"** → Edit manual → Simpan

### **Langkah 6: Simpan**
- Klik tombol **"Tambahkan Makanan"**
- Sistem akan validasi sebelum menyimpan
- Jika ada error → Perbaiki dulu
- Jika ada warning → Pilih "Lanjut" atau "Batal"

---

## ⚠️ Yang TIDAK BOLEH Diinput

### ❌ **Kalori**
- **Tidak boleh**: `0`, `-100`, `negatif apapun`
- **Minimal**: `1 kcal`
- **Maksimal**: Tidak ada batas, tapi realistis (contoh: < 2000 kcal per porsi)

### ❌ **Protein, Lemak, Karbohidrat**
- **Tidak boleh**: `negatif` (contoh: `-10`, `-5.5`)
- **Minimal**: `0` (boleh kosong atau 0 untuk makanan tertentu)
- **Maksimal**: Dibatasi oleh kalori (sistem akan warning jika tidak realistis)

### ❌ **Nama Makanan**
- **Tidak boleh**: Kosong
- **Harus**: Minimal 1 karakter

### ❌ **Jenis Makanan**
- **Tidak boleh**: Tidak dipilih
- **Harus**: Pilih salah satu dari dropdown

---

## ✅ Rekomendasi Input

### **1. Nama Makanan**
✅ **Gunakan nama yang jelas:**
- `Nasi Goreng` (bukan `ng`)
- `Ayam Bakar` (bukan `ayam`)
- `Salad Sayur` (bukan `salad`)

✅ **Kata kunci yang terdeteksi otomatis:**
- **Protein**: `ayam`, `daging`, `ikan`, `sapi`, `telur`, `tahu`, `tempe`
- **Karbohidrat**: `nasi`, `roti`, `pasta`, `mie`, `bihun`
- **Lemak**: `minyak`, `butter`, `kacang`, `biji`
- **Mixed**: `goreng`, `fried` (akan detect sebagai MIXED)
- **Balanced**: `buah`, `sayur`, `salad`

### **2. Kalori**
✅ **Rekomendasi per porsi:**
- **Sarapan**: 300-500 kcal
- **Makan Siang**: 500-800 kcal
- **Makan Malam**: 400-700 kcal
- **Cemilan**: 100-300 kcal

✅ **Contoh realistis:**
- Nasi putih (1 porsi): `200 kcal`
- Ayam goreng (1 potong): `300 kcal`
- Salad sayur: `150 kcal`
- Roti bakar: `250 kcal`

### **3. Macro Nutrients**

#### **Protein (gram)**
✅ **Rekomendasi per 300 kcal:**
- **Protein-heavy** (ayam, daging): 20-30g
- **Balanced**: 10-15g
- **Carb-heavy** (nasi, roti): 5-10g

#### **Lemak (gram)**
✅ **Rekomendasi per 300 kcal:**
- **Fat-heavy** (minyak, kacang): 20-35g
- **Balanced**: 5-10g
- **Protein-heavy**: 10-15g

#### **Karbohidrat (gram)**
✅ **Rekomendasi per 300 kcal:**
- **Carb-heavy** (nasi, roti): 50-60g
- **Balanced**: 40-50g
- **Protein-heavy**: 15-20g

---

## 🔍 Sistem Validasi

### **1. Hard Limits Validation**
Sistem akan **error** jika:
- Protein/Lemak/Karbohidrat di luar range yang mungkin untuk kalori tertentu
- Contoh: Protein 100g untuk 200 kcal (tidak mungkin)

### **2. Consistency Check**
Sistem akan **warning/error** jika:
- Total kalori dari macro ≠ kalori yang diinput
- **Toleransi**: 
  - ✅ **< 5%**: Info (OK)
  - ⚠️ **5-15%**: Warning (bisa lanjut)
  - ❌ **> 15%**: Error (harus perbaiki)

**Contoh:**
- Input kalori: `300 kcal`
- Macro total: `280 kcal` → Selisih 6.7% → ⚠️ Warning
- Macro total: `250 kcal` → Selisih 16.7% → ❌ Error

### **3. Realistic Ratio Check**
Sistem akan **warning** jika:
- Ratio macro tidak sesuai dengan kategori makanan
- Contoh: Protein 50% untuk makanan "Nasi" (seharusnya carb-heavy)

### **4. Zero Macro Check**
Sistem akan **warning** jika:
- Macro = 0g untuk kategori yang seharusnya punya macro tersebut
- Contoh: Protein 0g untuk "Ayam" (tidak realistis)

---

## 💡 Tips & Trik

### **Tip 1: Gunakan Checkbox "Sudah sesuai?"**
- ✅ **Centang** jika estimasi sudah sesuai → Langsung simpan tanpa edit
- ❌ **Uncheck** jika ingin edit manual

### **Tip 2: Perhatikan Visual Feedback**
- 🟢 **Hijau** (✓): Valid
- 🟡 **Kuning** (⚠️): Warning (bisa lanjut)
- 🔴 **Merah** (❌): Error (harus perbaiki)

### **Tip 3: Jika Kategori Tidak Terdeteksi**
- Sistem akan menggunakan estimasi **BALANCED** (P: 15%, L: 20%, K: 65%)
- Anda bisa edit manual jika perlu

### **Tip 4: Edit Macro Saat Kalori Berubah**
- Jika Anda **uncheck "Sudah sesuai?"** dan edit kalori
- Macro **tidak akan auto-update** (karena Anda sudah edit manual)
- Jika Anda **check "Sudah sesuai?"** dan edit kalori
- Macro **akan auto-update** sesuai kalori baru

### **Tip 5: Override Warning**
- Jika ada **warning**, Anda bisa pilih **"Lanjut"** untuk tetap menyimpan
- Berguna untuk diet khusus (keto, high-protein, dll)

---

## 🚨 Troubleshooting

### **Problem: Notifikasi biru muncul terus-menerus**
✅ **Solusi**: Sudah diperbaiki dengan debounce (tunggu 0.5 detik setelah selesai mengetik)

### **Problem: Macro tidak update saat kalori berubah**
✅ **Solusi**: 
- Pastikan checkbox **"Sudah sesuai?"** **checked**
- Atau uncheck → edit kalori → check lagi

### **Problem: Error "Macro di luar range"**
✅ **Solusi**: 
- Periksa apakah macro terlalu besar/kecil untuk kalori
- Gunakan estimasi otomatis sebagai referensi

### **Problem: Warning "Selisih kalori > 15%"**
✅ **Solusi**: 
- Edit macro agar total kalori dari macro ≈ kalori input
- Atau edit kalori agar sesuai dengan total macro

---

## 📊 Contoh Input yang Benar

### **Contoh 1: Nasi Goreng**
```
Nama: Nasi Goreng
Jenis: Makan Siang
Kalori: 400
Protein: 12g (auto)
Lemak: 13g (auto)
Karbohidrat: 58g (auto)
✅ Checkbox "Sudah sesuai?" → Simpan
```

### **Contoh 2: Ayam Bakar**
```
Nama: Ayam Bakar
Jenis: Makan Malam
Kalori: 300
Protein: 26g (auto)
Lemak: 13g (auto)
Karbohidrat: 19g (auto)
✅ Checkbox "Sudah sesuai?" → Simpan
```

### **Contoh 3: Salad Sayur (Edit Manual)**
```
Nama: Salad Sayur
Jenis: Cemilan
Kalori: 150
❌ Uncheck "Sudah sesuai?"
Protein: 5g (edit manual)
Lemak: 3g (edit manual)
Karbohidrat: 25g (edit manual)
✅ Simpan
```

---

## 📞 Butuh Bantuan?

Jika masih ada masalah atau pertanyaan, silakan:
1. Periksa kembali input Anda sesuai panduan di atas
2. Perhatikan visual feedback (warna border, icon)
3. Baca pesan error/warning dengan teliti
4. Gunakan estimasi otomatis sebagai referensi

---

**Selamat menggunakan fitur Tambah Makanan Kustom! 🎉**

