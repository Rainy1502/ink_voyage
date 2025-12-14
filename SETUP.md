# 🚀 Ink Voyage - Panduan Setup & Implementasi

## ✅ Project Selesai!

Aplikasi Flutter **Ink Voyage** telah berhasil dikembangkan dengan semua fitur terimplementasi dan siap untuk deployment/submission ke dosen.

## 📚 Fitur yang Telah Dibangun

### ✅ Sistem Authentication
- 🎬 Splash screen dengan animasi
- 🔐 Login dengan validasi email & password
- ✍️ Registrasi dengan pengecekan email

### ✅ Manajemen Buku & Konten
- 📖 List buku dengan filter & sorting
- ➕ Tambah buku (kategori, status, rating)
- ✏️ Edit detail buku
- 🗑️ Hapus buku dengan konfirmasi
- 👁️ View detail buku lengkap
- 🔍 Fitur pencarian

### ✅ Author & Moderator Features
- 📝 Aplikasi menjadi penulis (dengan moderasi)
- 📤 Publish buku baru (submit → pending → approved)
- 📊 Author Dashboard dengan statistik
- ✅ Moderator Dashboard untuk review aplikasi & buku
- 👥 Sistem role-based (reader, author, moderator)

### ✅ Tracking Progress & Analytics
- 📍 Update progress pembacaan halaman per halaman
- 📊 Indikator visual progress
- 📈 Dashboard statistik dengan chart
- 🎯 Real-time status updates
- ⭐ Rating & review sistem

### ✅ Profil & Pengaturan
- 👤 Informasi profil pengguna
- 📊 Statistik membaca (total buku, selesai, sedang dibaca)
- 🌙 Tema light mode
- 🔓 Logout functionality

### ✅ Arsitektur & Technology Stack
- **State Management**: Provider pattern dengan ChangeNotifier
- **Backend**: Firebase (Firestore, Authentication, Storage)
- **Database**: Cloud Firestore untuk data persistence
- **Routing**: Named routes dengan arguments
- **Theming**: Light theme dengan Material 3 design
- **Models**: Domain models dengan serialization
- **Widgets**: Reusable custom components

### ✅ Design Implementation
- ✓ Sesuai dengan spesifikasi Figma design
- ✓ Custom color scheme (Purple gradient: #9810FA → #8200DB)
- ✓ Font family: Arimo
- ✓ Material 3 design principles
- ✓ Responsive layouts dengan SafeArea
- ✓ Proper spacing dan alignment

---

## 🚀 Cara Menjalankan Aplikasi

### Prasyarat
- Flutter SDK ≥ 3.0.0
- Dart ≥ 2.19.0
- Android SDK atau Xcode
- Firebase Account (opsional, untuk full features)

### Option 1: Android Emulator
```bash
# Buka Android emulator dari Android Studio, kemudian:
flutter run
```

### Option 2: Physical Device (USB Debugging)
```bash
# Hubungkan device via USB dengan debugging enabled
flutter run
```

### Option 3: Web (Chrome)
```bash
flutter run -d chrome
```

### Option 4: iOS (macOS only)
```bash
flutter run -d ios
```

---

## 📁 Struktur Project

```
ink_voyage/
├── lib/
│   ├── main.dart                          # Entry point & routing
│   ├── models/                            # Data models
│   │   ├── user_model.dart                # User profile & auth
│   │   ├── author_application_model.dart  # Author workflow
│   │   └── book_model.dart                # Book structure
│   ├── providers/                         # State management
│   │   ├── auth_provider.dart             # Auth & user state
│   │   ├── book_provider.dart             # Book management
│   │   └── user_provider.dart             # User data
│   ├── screens/                           # UI Screens (20 total)
│   │   ├── home_screen.dart               # Dashboard pembaca
│   │   ├── discover_screen.dart           # Jelajahi buku
│   │   ├── profile_screen.dart            # Profil pengguna
│   │   ├── publish_book_screen.dart       # Publish buku
│   │   ├── author_dashboard_screen.dart   # Dashboard penulis
│   │   ├── moderator_dashboard_screen.dart # Dashboard moderator
│   │   ├── become_author_screen.dart      # Aplikasi author
│   │   ├── splash_screen.dart             # Loading screen
│   │   ├── login_screen.dart              # Login form
│   │   ├── register_screen.dart           # Registration form
│   │   └── ... (10+ screens lainnya)
│   ├── widgets/                           # Reusable components
│   │   ├── vertical_book_card.dart
│   │   ├── compact_book_card.dart
│   │   ├── custom_button.dart
│   │   ├── custom_input.dart
│   │   └── ...
│   ├── services/                          # Business logic
│   │   ├── author_application_service.dart
│   │   └── storage_service.dart
│   ├── themes/                            # Theming
│   │   └── light_theme.dart
│   └── utils/                             # Helper functions
│       ├── icon_helper.dart
│       └── app_assets.dart
├── assets/
│   └── images/
│       ├── icons/                         # SVG icons
│       └── sample_books/                  # Sample covers
├── android/                                # Android config
│   └── app/google-services.json           # Firebase config
├── ios/                                    # iOS config
├── pubspec.yaml                            # Dependencies
├── pubspec.lock                            # Locked versions
├── README.md                               # Documentation
└── SETUP.md                                # File ini
```

---

## 🔄 Alur Fitur Penting

### Authentication Flow
```
Splash Screen
    ↓
Check Login Status
    ├→ Sudah login → Home Screen
    └→ Belum login → Login/Register
        ├→ Login dengan email & password
        └→ Register → Auto login → Home Screen
```

### Author Application Flow
```
Reader membuka Become Author Screen
    ↓
Submit aplikasi → Status: Pending
    ↓
Moderator review di Moderator Dashboard
    ↓
Approve/Reject
    ├→ Approve → Role berubah jadi Author
    └→ Reject → Tetap Reader
```

### Book Publishing Flow
```
Author submit buku baru
    ↓
Book status: Pending
    ↓
Moderator review di Moderator Dashboard
    ↓
Approve
    ↓
Book status: Published
    ↓
Tampil di Discover Screen
```

### Reading Progress Flow
```
Reader buka Home Screen
    ↓
Klik buku → Detail Screen
    ↓
"Update Progress" → Input halaman
    ↓
Status otomatis update:
  ├→ 0% = Belum dibaca
  ├→ 1-99% = Sedang dibaca
  └→ 100% = Selesai
```

---

## 🧪 Testing Fitur

### Setup Pertama Kali
1. Jalankan app → Splash screen muncul
2. Klik "Register" untuk buat akun
3. Isi nama, email, password
4. Auto login → Masuk ke Home Screen

### Menambah Buku
1. Dari Home Screen, tekan tombol "+" 
2. Pilih kategori & isi detail buku
3. Buku muncul di list

### Update Progress Membaca
1. Tekan buku card
2. Klik "Update Progress"
3. Input halaman saat ini
4. Status otomatis update

### Lihat Statistik
1. Tap "Discover" / "Profile" untuk melihat stats
2. Lihat total buku, selesai, sedang dibaca
3. Lihat chart & analytics

### Moderator Features
1. Login dengan akun moderator (role: moderator)
2. Akses Moderator Dashboard
3. Review aplikasi penulis & buku
4. Approve/Reject submissions

---

## 📦 Dependencies Utama

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^latest           # Firebase core
  firebase_auth: ^latest            # Firebase authentication
  cloud_firestore: ^latest          # Cloud database
  firebase_storage: ^latest         # Cloud storage
  provider: ^latest                 # State management
  image_picker: ^latest             # Image selection
  intl: ^latest                     # Date formatting
  flutter_svg: ^latest              # SVG support
  fluttertoast: ^latest             # Toast notifications
```

---

## 🎨 Color Palette

### Light Mode (Aktif)
| Komponen | Color | Hex |
|----------|-------|-----|
| Primary | Purple | #9810FA |
| Secondary | Dark Purple | #8200DB |
| Tertiary | Cyan | #00D9FF |
| Background | Light Gray | #F9FAFB |
| Surface | White | #FFFFFF |
| Error | Red | #E7000B |

---

## 📝 Catatan Penting

### 1. Firebase Setup (Untuk Full Features)
Jika ingin menggunakan Firebase backend:
1. Buat project di Firebase Console
2. Download `google-services.json` untuk Android
3. Download `GoogleService-Info.plist` untuk iOS
4. Tempatkan di lokasi yang sesuai
5. Setup Firestore & Authentication rules

### 2. Asset & Image
- Assets tersimpan di `assets/images/`
- Untuk menambah image baru, update `pubspec.yaml`
- Run `flutter pub get` setelah update

### 3. Local Storage
- User data tersimpan di SharedPreferences
- Data tidak sync across devices
- Untuk production, gunakan Firebase Firestore

### 4. Image Handling
- URL images: Harus valid HTTP/HTTPS URLs
- Uploaded images: Tersimpan sebagai file paths
- Gunakan Firebase Storage untuk production

### 5. Authentication
- Sekarang menggunakan Firebase Authentication
- Email & password based
- Untuk production, tambahkan: OAuth, biometric, dll

---

## 🔧 Customization Tips

### Mengubah Warna App
Edit `lib/themes/light_theme.dart`:
```dart
primaryColor: const Color(0xFF9810FA),  // Ubah primary color
```

### Menambah Screen Baru
1. Buat file di `lib/screens/nama_screen.dart`
2. Add route di `lib/main.dart` onGenerateRoute:
```dart
case '/nama-route':
  return MaterialPageRoute(builder: (_) => NamaScreen());
```
3. Navigate menggunakan: `Navigator.pushNamed(context, '/nama-route')`

### Modifikasi Book Model
1. Update `lib/models/book_model.dart`
2. Update `toMap()` dan `fromMap()` methods
3. Adjust provider methods di `lib/providers/book_provider.dart`

### Menambah Firebase Rules
Edit Firestore Security Rules untuk kontrol akses data.

---

## ❌ Troubleshooting

### Issue: Hot reload tidak work
**Solusi**: Hot restart dengan `R` di terminal atau restart button

### Issue: Assets tidak load
**Solusi**: 
```bash
flutter clean
flutter pub get
flutter run
```

### Issue: Firebase errors
**Solusi**: Check `google-services.json` dan Firebase configuration

### Issue: Provider not found errors
**Solusi**: Ensure wrapped dengan `MultiProvider` di main.dart

### Issue: Build errors di Android
**Solusi**:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

---

## ✅ Pre-Submission Checklist

- [x] Semua fitur sudah tested
- [x] Tidak ada compilation errors
- [x] Tidak ada lint warnings
- [x] README.md sudah comprehensive
- [x] .gitignore sudah optimal
- [x] analysis_options.yaml sudah configured
- [x] Code sudah formatted: `flutter format .`
- [x] Code sudah analyzed: `flutter analyze`
- [x] Build sudah tested

---

## 🎉 Selesai!

App Ink Voyage siap untuk:
- ✅ Submission ke dosen
- ✅ Push ke GitHub
- ✅ Deployment ke app store (dengan additional setup)

### Langkah Terakhir:
```bash
# 1. Format code
flutter format .

# 2. Analyze code
flutter analyze

# 3. Run final test
flutter run

# 4. Commit & push
git add .
git commit -m "Final: Clean repo for submission"
git push origin main
```

---

**Happy coding! 🚀 Semoga sukses submission ke dosen!**

*Last updated: December 2025*
