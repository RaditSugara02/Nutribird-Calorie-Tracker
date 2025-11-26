
## TASK: Implementasi Fitur Image Crop/Edit untuk Food & Profile Photo

### PROJECT CONTEXT
Platform: Android-Only Flutter Application (IDE: VS Code/Android Studio)
Aplikasi: Calorie Tracker dengan fitur:
- Upload foto makanan custom
- Upload foto profil user
- Semua foto perlu bisa di-crop/edit sebelum disimpan

### CURRENT SITUATION
Saat user pilih foto dari galeri, aplikasi FORCE CLOSE.
Ini karena:
1. Permission handling belum proper
2. Image picker belum terintegrase dengan crop
3. Flow dari gallery → crop → save belum jelas

### WHAT WE WANT TO BUILD

**Feature Requirements:**
1. User tap foto → Pick image dari gallery
2. Setelah pick, langsung buka Crop Screen (full-screen atau modal dialog)
3. Di Crop Screen: 
   - Lihat preview foto
   - Bisa drag/zoom/rotate untuk adjust
   - Ada grid overlay untuk guide
   - Ada aspect ratio options (square untuk profile, flexible untuk food)
   - Save button untuk confirm crop
4. Setelah crop, kembali ke previous screen dengan cropped image
5. Support: Profile Photo, Food Photo, Meal/Dish Photo

### IMPLEMENTATION APPROACH (RECOMMENDED)

**PLUGIN RECOMMENDATIONS:**
- ✅ `image_picker: ^1.0.7` - Pick image dari gallery
  * Why: Official Flutter plugin, stable, well-maintained
  * NOT: file_picker (terlalu heavy untuk image picking)
  * NOT: photo_manager (overkill, lebih untuk gallery app)

- ✅ `image_cropper: ^5.0.1` - Crop & edit image
  * Why: Dedicated image cropper dengan grid overlay, aspect ratio control, rotation
  * Why: Built-in Android UI yang smooth & familiar
  * NOT: crop_image (deprecated)
  * NOT: custom crop (terlalu kompleks)

- ✅ `permission_handler: ^11.4.4` - Request permissions
  * Why: Handle READ_EXTERNAL_STORAGE, WRITE_EXTERNAL_STORAGE, READ_MEDIA_IMAGES (Android 13+)
  * NOT: built-in permissions (kurang control)

**FLOW ARCHITECTURE (Recommended):**
