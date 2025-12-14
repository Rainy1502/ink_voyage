# 📚 Ink Voyage

**Aplikasi mobile Flutter untuk menemukan, membaca, dan menerbitkan karya literasi digital.**

Ink Voyage adalah platform membaca dan penerbitan yang memungkinkan pembaca menemukan karya terbaru dan penulis menerbitkan buku mereka dengan mudah. Aplikasi ini dibangun dengan Flutter dan menggunakan Firebase sebagai backend.

---

## 📋 Daftar Isi

- [Fitur Utama](#fitur-utama)
- [Prasyarat Sistem](#prasyarat-sistem)
- [Instalasi & Setup](#instalasi--setup)
- [Menjalankan Aplikasi](#menjalankan-aplikasi)
- [Struktur Proyek](#struktur-proyek)
- [Panduan Pengembangan](#panduan-pengembangan)
- [Arsitektur & Alur Data](#arsitektur--alur-data)
- [Kontribusi](#kontribusi)
- [Lisensi](#lisensi)

---

## ✨ Fitur Utama

### Untuk Pembaca
- 📖 **Discover Screen**: Jelajahi buku-buku baru dengan filter genre dan sort
- 🏠 **Home Screen**: Dashboard personal dengan daftar buku dan progress membaca
- 📊 **Progress Tracking**: Catat progress membaca Anda secara real-time
- ⭐ **Rating & Review**: Beri rating dan ulasan untuk buku yang Anda baca
- 👥 **Following System**: Ikuti penulis favorit Anda

### Untuk Penulis
- ✍️ **Author Application**: Ajukan menjadi penulis (dengan moderasi)
- 📤 **Publish Books**: Upload karya dengan metadata lengkap
- 📊 **Author Dashboard**: Monitor statistik buku (views, readers, ratings)
- ✏️ **Book Management**: Kelola buku yang dipublikasikan
- 📈 **Analytics**: Lihat performa buku dan engagement pembaca

### Untuk Moderator
- ✅ **Author Application Review**: Review dan approve aplikasi penulis baru
- 📚 **Book Moderation**: Review dan approve buku sebelum dipublikasikan
- 📊 **Moderator Dashboard**: Dashboard dengan statistik sistem

---

## 🔧 Prasyarat Sistem

| Komponen | Versi | Deskripsi |
|----------|-------|----------|
| **Flutter SDK** | ≥ 3.0.0 | Framework mobile development |
| **Dart** | ≥ 2.19.0 | Bahasa pemrograman untuk Flutter |
| **Android SDK** | ≥ API 21 | Untuk build Android |
| **Xcode** | ≥ 14.0 | Untuk build iOS (macOS only) |
| **Git** | ≥ 2.0 | Version control |
| **Firebase Account** | - | Backend & authentication |

### Download & Install

1. **Flutter**: https://flutter.dev/docs/get-started/install
2. **Android Studio**: https://developer.android.com/studio
3. **Git**: https://git-scm.com/download

---

## 📦 Instalasi & Setup

### 1. Clone Repository

```bash
git clone https://github.com/Rainy1502/ink_voyage.git
cd ink_voyage
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Konfigurasi Firebase

1. Buat project baru di [Firebase Console](https://console.firebase.google.com/)
2. Download `google-services.json` (Android) atau `GoogleService-Info.plist` (iOS)
3. Tempatkan file di lokasi yang sesuai:
   - **Android**: `android/app/google-services.json`
   - **iOS**: `ios/Runner/GoogleService-Info.plist`

### 4. Inisialisasi Firebase CLI (Opsional)

```bash
flutter pub global activate flutterfire_cli
flutterfire configure
```

---

## 🚀 Menjalankan Aplikasi

### Development Mode

```bash
# Jalankan di emulator/device yang terhubung
flutter run

# Jalankan di emulator Android tertentu
flutter run -d <device_id>

# Jalankan di web (experimental)
flutter run -d web-server
```

### Build & Deployment

```bash
# Build APK (Android)
flutter build apk --release

# Build App Bundle (untuk Google Play)
flutter build appbundle

# Build iOS (macOS only)
flutter build ios --release

# Build Web
flutter build web
```

---

## 📁 Struktur Proyek

```
ink_voyage/
├── lib/
│   ├── main.dart                          # Entry point aplikasi
│   ├── models/                            # Data models
│   │   ├── user_model.dart                # User profile & auth data
│   │   ├── author_application_model.dart  # Author application workflow
│   │   └── book_model.dart                # Book data structure
│   ├── providers/                         # State management (Provider)
│   │   ├── auth_provider.dart             # Authentication & user state
│   │   ├── book_provider.dart             # Book management state
│   │   └── user_provider.dart             # User data state
│   ├── screens/                           # UI Screens (20 screens)
│   │   ├── home_screen.dart               # Dashboard pembaca
│   │   ├── discover_screen.dart           # Jelajahi buku baru
│   │   ├── profile_screen.dart            # Profil pengguna
│   │   ├── publish_book_screen.dart       # Publish buku baru
│   │   ├── author_dashboard_screen.dart   # Dashboard penulis
│   │   ├── moderator_dashboard_screen.dart # Dashboard moderator
│   │   ├── become_author_screen.dart      # Aplikasi menjadi penulis
│   │   ├── splash_screen.dart             # Loading screen
│   │   ├── login_screen.dart              # Login form
│   │   ├── register_screen.dart           # Registration form
│   │   └── ...
│   ├── widgets/                           # Reusable UI components
│   │   ├── vertical_book_card.dart        # Book card display
│   │   ├── compact_book_card.dart         # Compact book card
│   │   ├── large_book_card.dart           # Large book card
│   │   ├── custom_button.dart             # Custom button styles
│   │   ├── custom_input.dart              # Custom input fields
│   │   └── book_card.dart                 # Standard book card
│   ├── services/                          # Business logic & Firestore
│   │   ├── author_application_service.dart # Author application logic
│   │   └── storage_service.dart           # Cloud storage handling
│   ├── themes/                            # App theming
│   │   └── light_theme.dart               # Light theme configuration
│   ├── utils/                             # Helper functions
│   │   ├── icon_helper.dart               # SVG icon management
│   │   └── app_assets.dart                # Asset paths constant
│   └── models/
│       └── [auto-generated files]         # Auto-generated (ignore)
├── assets/
│   └── images/
│       ├── icons/                         # SVG icons & app icons
│       ├── sample_books/                  # Sample book covers
├── android/                                # Android-specific code
│   ├── app/
│   │   ├── google-services.json           # Firebase config
│   │   └── src/
│   └── ...
├── ios/                                    # iOS-specific code
├── web/                                    # Web-specific code
├── linux/, macos/, windows/                # Desktop support (experimental)
├── pubspec.yaml                            # Project dependencies
├── pubspec.lock                            # Locked dependency versions
├── README.md                               # Project documentation
├── .gitignore                              # Git ignore rules
└── SETUP.md                                # Initial setup guide
```

---

## 🛠️ Panduan Pengembangan

### Analisis & Formatting

```bash
# Analisis statis (menemukan potential bugs)
flutter analyze

# Format kode sesuai Dart style guide
flutter format .

# Fix otomatis dengan `dart fix`
dart fix --apply
```

### Testing

```bash
# Jalankan semua tests
flutter test

# Jalankan test dengan coverage
flutter test --coverage

# Jalankan test spesifik
flutter test test/unit_test.dart
```

### Debug

```bash
# Jalankan dengan debug mode verbose
flutter run -v

# Attach debugger ke running app
flutter attach
```

---

## 🏗️ Arsitektur & Alur Data

### Authentication Flow

```
User → Firebase Auth → AuthProvider → App State Update
```

### Author Application Flow

```
Reader submits application
  ↓
AuthorApplicationService.submitApplication()
  ↓ Creates: author_applications/{id} with status='pending'
  ↓ Updates: users/{id}.authorApplicationStatus='pending'
  ↓
Moderator reviews in ModeratorDashboardScreen
  ↓
Moderator approves/rejects
  ↓ Updates: author_applications/{id}.status, users/{id}.role
  ↓
User receives notification and becomes author
```

### Publishing Flow

```
Author submits book
  ↓
Create: published_books/{id} with status='pending'
  ↓
Moderator reviews in ModeratorDashboardScreen
  ↓
Moderator approves
  ↓ Updates: published_books/{id}.status='published'
  ↓
Book appears in Discover screen
```

### State Management

- **Provider Pattern** untuk state management
- **ChangeNotifier** untuk reactive updates
- **StreamBuilder** untuk real-time Firestore data
- **FutureBuilder** untuk one-time async operations

---

## 📚 Dependencies Utama

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^latest
  firebase_auth: ^latest
  cloud_firestore: ^latest
  provider: ^latest
  intl: ^latest
  flutter_svg: ^latest
```

Lihat `pubspec.yaml` untuk dependencies lengkap.

---

## 🤝 Kontribusi

Kami menerima kontribusi! Berikut cara berkontribusi:

1. **Fork** repository ini
2. **Buat branch** fitur baru: `git checkout -b feature/nama-fitur`
3. **Commit** perubahan: `git commit -m 'Tambah: deskripsi fitur'`
4. **Push** ke branch: `git push origin feature/nama-fitur`
5. **Buat Pull Request** dengan deskripsi lengkap

### Pedoman Kode

- Ikuti [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Gunakan meaningful variable names
- Tambahkan comments untuk logic yang kompleks
- Jalankan `flutter analyze` dan `flutter format` sebelum commit

---

## 📖 Dokumentasi Teknis

- [Setup Guide](./SETUP.md) - Panduan setup awal

---

## 📝 Lisensi

Proyek ini dibuat sebagai mini project untuk mata kuliah "Praktikum Pemrograman Sistem Bergerak".

---

## 📧 Kontak

- **Author**: Rainy1502
- **GitHub**: https://github.com/Rainy1502/ink_voyage
- **Issues**: Silakan buat issue untuk bug reports atau feature requests

---

**Terakhir diupdate**: Desember 2025

*Happy coding! 🎉*

Catatan lisensi
- Proyek ini dibuat untuk tugas perkuliahan. Jika menggunakan aset eksternal, patuhi lisensi dan berikan atribusi bila diperlukan.
