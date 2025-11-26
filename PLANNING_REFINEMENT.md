## TASK: Review & Refinement Planning - Sebelum Implementasi Macro Validation Feature

### CONTEXT
Saya telah membuat rencana implementasi fitur "Smart Macro Estimation + Validation" untuk aplikasi Calorie Tracker Android.
Rencana sudah 80% lengkap, tapi ada beberapa aspek PENTING yang perlu ditambahkan untuk mencegah edge cases dan bugs.

### ANALISIS CURRENT PLANNING
Rencana saat ini SUDAH MENCAKUP:
✓ Smart default estimation (category detection + ratio calculation)
✓ Checkbox "Sudah sesuai?" dengan default checked
✓ Real-time validation & consistency check
✓ UI/UX improvements (auto-fill, visual feedback, real-time validation)
✓ Code structure (MacroEstimator, MacroValidator, helpers, state management)

Rencana saat ini BELUM MENCAKUP:
✗ Hard limits formula yang detail dan terstruktur
✗ Realistic ratio validation per kategori makanan
✗ Special case handling (0g macro, unconventional diet)
✗ Alert message factory yang terstruktur
✗ State model yang track validation status secara detail
✗ Architecture yang future-proof untuk database lookup

### CRITICAL ADDITIONS YANG DIPERLUKAN

#### ADD 1: Hard Limits Formula Constants & Utilities
**Lokasi:** lib/utils/macro_validator.dart

**Yang diperlukan:**
- Constants untuk macro kalori ratio (protein 4 kcal/g, fat 9 kcal/g, carb 4 kcal/g)
- Constants untuk realistic hard limits:
  * Max realistic protein: 75g per 300 kcal (~0.25g per kcal)
  * Max realistic fat: 35g per 300 kcal (~0.12g per kcal)
  * Max realistic carb: 75g per 300 kcal (~0.25g per kcal)
- Method calculateHardLimitMin(String macro, double kalori): double
  * Protein: Max(0, kalori/200)
  * Fat: Max(0, kalori/1800)
  * Carb: Max(0, kalori/400)
- Method calculateHardLimitMax(String macro, double kalori): double
  * Protein: Min(999, kalori/4)
  * Fat: Min(999, kalori/9)
  * Carb: Min(999, kalori/4)
- Method validateHardLimits(double protein, double fat, double carb, double kalori): 
  * Return ValidationResult { isValid: bool, violations: List<MacroViolation> }

**Gunakan:**
- Untuk prevent user input 0g protein untuk kalori 300 kcal
- Untuk prevent user input 500g carb untuk kalori 300 kcal
- Untuk hard-block invalid input di error level

---

#### ADD 2: Realistic Ratio Validation per Kategori
**Lokasi:** lib/utils/macro_validator.dart

**Yang diperlukan:**
- Enum/Map untuk realistic ratio range per kategori:

PROTEIN_HEAVY (Ayam, Daging, Ikan, Telur):

Protein: 30-50%

Fat: 20-40%

Carb: 10-30%

Flags: P < 15%, L > 60%, K > 40%

CARB_HEAVY (Nasi, Roti, Pasta, Umbi):

Protein: 5-15%

Fat: 5-20%

Carb: 65-85%

Flags: K < 50%, P > 25%, L > 30%

FAT_HEAVY (Minyak, Butter, Kacang, Biji):

Protein: 0-20%

Fat: 60-100%

Carb: 0-20%

Flags: P > 30%, L < 50%

MIXED (Nasi + Lauk, Pizza):

Protein: 15-25%

Fat: 15-30%

Carb: 50-70%

Flags: Any > 70% or < 5%

BALANCED (Buah, Sayur, Unknown):

Protein: 10-25%

Fat: 10-30%

Carb: 50-75%

text

- Method calculateRatioPercent(double macro, double totalKalori, double ratioPerGram): double
  * Contoh: calculateRatioPercent(25, 300, 4) → 33.3%
  
- Method validateRealisticRatio(double protein, double fat, double carb, FoodCategory category):
  * Return RatioValidationResult { isRealistic: bool, flags: List<RatioFlag>, severity: AlertSeverity }
  * RatioFlag: { flagType: String, message: String, suggestion: String? }

- Method detectUnconventionalDiet(double protein, double fat, double carb):
  * Return { isUnconventional: bool, dietType: String? } // dietType: 'keto', 'high-protein', dst
  * Untuk allow override jika user intentional

**Gunakan:**
- Untuk warn "Nasi Goreng dengan 90% lemak"
- Untuk detect "Makanan ini seimbang atau extreme?"
- Untuk respect unconventional diet user (keto, intermittent fasting)

---

#### ADD 3: Special Case Handlers
**Lokasi:** lib/utils/macro_validator.dart

**Yang diperlukan:**
- Method validateZeroMacro(String macro, FoodCategory category):
  * Protein 0g: Allow only if category = CARB_HEAVY or FAT_HEAVY
  * Fat 0g: Allow only if category = CARB_HEAVY or PROTEIN_HEAVY
  * Carb 0g: Allow only if category = PROTEIN_HEAVY or FAT_HEAVY
  * Otherwise: Return AlertResult { severity: WARNING, message: String, requiresConfirmation: bool }

- Method handleUnknownCategory(double kalori):
  * Jika kategori tidak terdeteksi, use BALANCED ratio
  * Return { estimatedProtein, estimatedFat, estimatedCarb, category: 'UNKNOWN/BALANCED' }

- Method createOverridePrompt(ValidationResult violation):
  * Untuk user yang tahu apa yang mereka lakukan
  * Return AlertResult { severity: WARNING, message, confirmationText: "Saya yakin" }

**Gunakan:**
- Untuk allow "0g Carb" untuk daging (realistis)
- Untuk block "0g Protein" untuk nasi (tidak realistis)
- Untuk fallback kategori unknown ke balanced

---

#### ADD 4: Alert Message Factory
**Lokasi:** lib/utils/alert_message_factory.dart (FILE BARU)

**Yang diperlukan:**
- Class AlertMessage { severity: AlertSeverity, title: String, message: String, actionButtons: List<ActionButton> }
- AlertSeverity: enum { INFO, WARNING, ERROR }
- ActionButton: { text: String, onPressed: Function, isDestructive: bool }

- Method generateConsistencyErrorMessage(double macroKal, double inputKal, double percent):
  * Format: "ℹ️/⚠️/❌ Macro Anda total {macroKal} kcal, tapi Anda input {inputKal} kcal. Selisih {diff} kcal ({percent}%)."
  * Return: AlertMessage dengan severity berdasarkan percent
  * < 5%: INFO + no confirmation needed
  * 5-15%: WARNING + "Yakin? [Tidak] [Lanjut]"
  * > 15%: ERROR + "Silakan edit macro. [Batal Edit]"

- Method generateHardLimitViolationMessage(String macro, double value, double min, double max):
  * Format: "❌ {macro} {value}g di luar range {min}g - {max}g untuk {kalori} kcal."
  * Return: AlertMessage ERROR + suggestion ke midpoint

- Method generateRealisticRatioWarningMessage(String flagType, double percent, String expected, FoodCategory category):
  * Format: "⚠️ Anda input {percent}% {macro} untuk '{category}'. Biasanya {expected}%. Cek lagi?"
  * Return: AlertMessage WARNING + [Batal Edit] [Review]

- Method generateZeroMacroWarningMessage(String macro, FoodCategory category, bool isAllowed):
  * Jika allowed: INFO "Makanan tanpa {macro} untuk {category} - OK"
  * Jika not allowed: WARNING "⚠️ {macro} 0g tidak realistis untuk {category}. Yakin?"

- Method generateCategoryNotFoundMessage(String foodName):
  * Format: "ℹ️ Kategori '{foodName}' tidak terdeteksi. Menggunakan estimasi balanced. Edit jika perlu."
  * Return: AlertMessage INFO

**Gunakan:**
- Centralized message generation
- Konsisten tone & format semua message
- Easy to modify message tanpa ubah logic

---

#### ADD 5: State Model dengan Validation Tracking
**Lokasi:** lib/models/add_custom_food_state.dart (FILE BARU)

**Yang diperlukan:**
class AddCustomFoodState {
// Basic Input
String foodName;
double kalori;
FoodCategory detectedCategory;

// Estimated Macro (auto-generated)
double estimatedProtein;
double estimatedFat;
double estimatedCarb;

// User Input (if edited)
double? userProtein;
double? userFat;
double? userCarb;

// Validation Status
ValidationStatus validationStatus; // VALID, WARNING, ERROR, INITIAL
List<AlertMessage> alerts; // Multiple alerts per field

// User Action
bool userAcceptedDefault; // Checkbox "Sudah sesuai?"
bool userOverriddenValidation; // User click "Lanjut" despite warning

// Computed Properties (getters)
double get activeProtein => userProtein ?? estimatedProtein;
double get activeFat => userFat ?? estimatedFat;
double get activeCarb => userCarb ?? estimatedCarb;

double get macroKaloriTotal =>
(activeProtein * 4) + (activeFat * 9) + (activeCarb * 4);

bool get isConsistent =>
(macroKaloriTotal / kalori).between(0.9, 1.1);

bool get isReadyToSubmit =>
validationStatus == VALID || userOverriddenValidation;

// Methods
void updateUserProtein(double value) { ... }
void updateUserFat(double value) { ... }
void updateUserCarb(double value) { ... }
void acceptDefault() { userAcceptedDefault = true; }
void rejectDefault() { userAcceptedDefault = false; }
ValidationResult validateCurrent() { ... }
void clearUserEdits() { userProtein = null; userFat = null; userCarb = null; }
}

enum ValidationStatus { INITIAL, VALID, WARNING, ERROR }

text

- Add method `validate()`: trigger full validation chain
  * Hard limits check
  * Consistency check
  * Realistic ratio check
  * Special case check
  * Return: ValidationResult { status, alerts: List<AlertMessage> }

- Add method `getAlertForField(String fieldName)`: return alert untuk field tertentu
  * Untuk UI menampilkan alert di field-level

**Gunakan:**
- SingleValueNotifier atau BLoC untuk state management
- Track validation status real-time saat user edit
- Easy testing karena semua logic ter-encapsulate

---

#### ADD 6: Architecture untuk Database Lookup (Future-Proofing)
**Lokasi:** lib/utils/macro_estimator.dart

**Yang diperlukan:**
- Abstract class NutritionDataSource { Future<NutritionData?> lookup(String foodName); }
- Implementation 1: LocalNutritionDataSource (hardcoded, MVP)
- Implementation 2: RemoteNutritionDataSource (untuk future API/database)
- Method di MacroEstimator: `tryLookupFromNutritionDb(String foodName): Future<NutritionData?>`
  * Jika found: return actual data
  * Jika not found: fallback ke category estimation

**Gunakan:**
- MVP bisa langsung use LocalNutritionDataSource
- Future bisa swap ke RemoteNutritionDataSource tanpa ubah logic
- Extensible architecture

---

### IMPLEMENTATION STEPS (Updated)

**Phase 1: Foundation (ADD 1 & ADD 4 & ADD 5)**
- [ ] Create MacroValidator dengan hard limits constants
- [ ] Create AlertMessageFactory
- [ ] Create AddCustomFoodState model
- [ ] Unit test untuk hard limits formula

**Phase 2: Validation Logic (ADD 2 & ADD 3)**
- [ ] Add realistic ratio validation
- [ ] Add special case handlers
- [ ] Add unconventional diet detection
- [ ] Unit test untuk edge cases

**Phase 3: UI Integration**
- [ ] Update AddCustomFoodScreen dengan state management
- [ ] Integrate real-time validation
- [ ] Add visual feedback (colors, icons)
- [ ] Add alert dialogs

**Phase 4: Future-Proofing (ADD 6)**
- [ ] Create abstract NutritionDataSource
- [ ] Create LocalNutritionDataSource
- [ ] Architecture untuk remote lookup

---

### DELIVERABLES (Updated)

✓ MacroValidator class dengan:

Hard limits constants & methods

Realistic ratio validation

Special case handlers

Full validation chain

✓ AlertMessageFactory class dengan:

Message templates

Alert generation methods

Consistent tone & format

✓ AddCustomFoodState model dengan:

All validation tracking

Computed properties

Full validation methods

✓ NutritionDataSource architecture

✓ Updated AddCustomFoodScreen dengan:

State management integration

Real-time validation

Visual feedback

Alert system

✓ Unit tests untuk:

Hard limits formula

Consistency check

Realistic ratio validation

Edge cases & special cases

text

### CRITICAL SUCCESS FACTORS

1. **Realistic Ratio Validation** - HARUS ada, jangan skip
2. **Special Case Handling** - HARUS ada, untuk edge case user
3. **Alert Factory** - HARUS ada, untuk consistent messaging
4. **State Model** - HARUS ada, untuk track validation status
5. **Future Architecture** - Nice-to-have, tapi bikin code lebih clean

### TIMELINE

- Phase 1: 2-3 jam
- Phase 2: 2-3 jam
- Phase 3: 2-3 jam
- Phase 4: 1-2 jam
- Testing & refinement: 2-3 jam

---

## NEXT STEPS

Sebelum implementasi, aku sudah siap dengan:
1. ✓ Detailed hard limits formula
2. ✓ Realistic ratio ranges per kategori
3. ✓ Special case handling logic
4. ✓ Alert message templates
5. ✓ State model structure
6. ✓ Architecture untuk database lookup

Apakah Anda menyetujui ke-6 addition ini?
Ketik "PROCEED" untuk mulai implementasi dengan foundation yang SOLID.
