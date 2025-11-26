## TASK: Update Aplikasi Calorie Tracker - Opsi 2 dengan Validation & Constraint

### CONTEXT
Saya sedang mengembangkan aplikasi Android Calorie Tracker. Fitur utama adalah user bisa menambahkan menu makanan custom dengan input:
- Nama Makanan
- Jumlah Kalori (kcal) - WAJIB
- Protein (gram) - OPTIONAL tapi bisa di-edit
- Lemak (gram) - OPTIONAL tapi bisa di-edit
- Karbo (gram) - OPTIONAL tapi bisa di-edit

Saat ini, implementasi menggunakan OPSI 2:
User input HANYA kalori (wajib), lalu sistem auto-generate estimasi macro (protein, lemak, karbo).
User bisa edit ketiga macro tersebut untuk accuracy.

### PROBLEM YANG PERLU DIATASI

**Masalah Umum yang Harus Di-Handle:**

1. **User Laziness / Adoption Barrier**
   - Banyak user males edit estimasi macro
   - Solusi: Buat editing optional, bukan wajib. Set "default acceptance" di checkbox "Sudah sesuai?"

2. **User Tidak Tahu Actual Macro Data**
   - User hanya tahu kalori, tidak tahu protein/lemak/karbo dari label
   - Solusi: Smart category detection dari nama makanan + berikan suggested ratio realistis

3. **Data Consistency & Validation**
   - User bisa input macro yang inconsistent dengan kalori (contoh: P 50g + L 5g + K 5g = 265 kcal, tapi user input 300 kcal)
   - Solusi: Validasi real-time consistency dengan margin tolerance 20% (5-15% warning, >15% reject)

4. **Unrealistic / Extreme Input**
   - User bisa input 0g protein, atau 500g karbo untuk makanan 300 kcal (nonsense)
   - Solusi: Hard limits validation + realistic ratio check per kategori makanan

5. **User Control & Trust**
   - Jangan hard-block user, tapi guide mereka ke data yang lebih realistis
   - Solusi: Smart alerts (info, warning, error) dengan clear explanation

### REQUIREMENT YANG HARUS DIIMPLEMENTASIKAN

#### A. SMART DEFAULT ESTIMATION
- Input kalori dari user
- Auto-detect KATEGORI makanan dari nama:
  * "Goreng" → CARB + FAT (nasi goreng, ayam goreng)
  * "Ayam/Daging/Ikan" → PROTEIN + FAT
  * "Nasi/Roti/Pasta" → CARB-heavy
  * "Telur/Tahu" → PROTEIN
  * "Minyak/Butter" → PURE FAT
  * "Buah/Sayur" → CARB + minimal fat/protein
  
- Berdasarkan kategori, generate RATIO realistis:
  * Protein-Heavy (Ayam): P 35%, L 40%, K 25%
  * Carb-Heavy (Nasi): P 10%, L 10%, K 80%
  * Fat-Heavy (Minyak): P 0%, L 100%, K 0%
  * Mixed (Nasi Goreng): P 12%, L 30%, K 58%

- Convert ratio jadi angka aktual berdasarkan kalori user

#### B. VALIDATION LOGIC - HARD LIMITS
Validasi range per macro (jangan boleh ditembus):

