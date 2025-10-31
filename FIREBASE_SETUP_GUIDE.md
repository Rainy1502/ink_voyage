# 🔥 Firebase Setup Guide - InkVoyage

## 📋 Daftar Isi
1. [Persiapan Firebase Console](#1-persiapan-firebase-console)
2. [Install Dependencies](#2-install-dependencies)
3. [Konfigurasi Firebase](#3-konfigurasi-firebase)
4. [Struktur Database Firestore](#4-struktur-database-firestore)
5. [Firebase Authentication Setup](#5-firebase-authentication-setup)
6. [Firebase Storage Setup](#6-firebase-storage-setup)
7. [Security Rules](#7-security-rules)
8. [Testing](#8-testing)

---

## 1. Persiapan Firebase Console

### Step 1.1: Buat Project Firebase
1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Klik **"Add project"** atau **"Tambahkan project"**
3. Nama project: **`ink-voyage`** (atau nama lain sesuai keinginan)
4. Enable Google Analytics (opsional, recommended untuk tracking)
5. Klik **"Create project"**

### Step 1.2: Register App
Setelah project dibuat:

#### **Untuk Android:**
1. Klik icon Android di Firebase Console
2. Android package name: `com.example.ink_voyage` 
   - Cek di `android/app/build.gradle.kts` → `namespace`
3. App nickname: `InkVoyage Android`
4. Download `google-services.json`
5. Letakkan file di: `android/app/google-services.json`

#### **Untuk iOS:** (jika perlu)
1. Klik icon iOS di Firebase Console
2. iOS bundle ID: `com.example.inkVoyage`
   - Cek di `ios/Runner.xcodeproj/project.pbxproj`
3. Download `GoogleService-Info.plist`
4. Letakkan di: `ios/Runner/GoogleService-Info.plist`

---

## 2. Install Dependencies

### Step 2.1: Update `pubspec.yaml`
Tambahkan dependencies Firebase di `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Existing dependencies
  provider: ^6.1.2
  image_picker: ^1.0.7
  shared_preferences: ^2.2.3
  http: ^1.2.1
  intl: ^0.19.0
  fl_chart: ^0.66.2
  flutter_svg: ^2.0.10
  
  # Firebase dependencies - ADD THESE
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.1
  cloud_firestore: ^5.4.4
  firebase_storage: ^12.3.4
```

### Step 2.2: Install Packages
Jalankan di terminal:
```bash
flutter pub get
```

---

## 3. Konfigurasi Firebase

### Step 3.1: Konfigurasi Android

#### 3.1.1: Update `android/build.gradle.kts`
Tambahkan di bagian atas file:
```kotlin
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.2")
    }
}
```

#### 3.1.2: Update `android/app/build.gradle.kts`
Di bagian paling bawah file, tambahkan:
```kotlin
apply(plugin = "com.google.gms.google-services")
```

Dan pastikan di bagian `dependencies`:
```kotlin
dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.5.1"))
    implementation("com.google.firebase:firebase-analytics")
}
```

### Step 3.2: Initialize Firebase di Flutter

#### 3.2.1: Update `lib/main.dart`
```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Import providers
import 'providers/book_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/user_provider.dart';
import 'providers/auth_provider.dart'; // NEW

// Import themes
import 'themes/light_theme.dart';

// Import screens
import 'screens/splash_screen.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()), // NEW
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => BookProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'InkVoyage',
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
```

---

## 4. Struktur Database Firestore

### 4.1: Collections Structure

```
firestore/
├── users/
│   └── {userId}/
│       ├── id: String
│       ├── name: String
│       ├── email: String
│       ├── joinedDate: Timestamp
│       └── profileImageUrl: String? (nullable)
│
└── books/
    └── {bookId}/
        ├── id: String
        ├── userId: String (foreign key ke users)
        ├── title: String
        ├── author: String
        ├── imageUrl: String
        ├── totalPages: Number
        ├── currentPage: Number
        ├── status: String ('reading' | 'completed' | 'not-started')
        ├── genre: String? (nullable)
        ├── rating: Number? (nullable, 1-5)
        ├── notes: String? (nullable)
        ├── createdAt: Timestamp
        └── updatedAt: Timestamp? (nullable)
```

### 4.2: Indexes (Optional - untuk query performance)

Di Firebase Console → Firestore Database → Indexes:

**Composite Index untuk Books:**
- Collection: `books`
- Fields indexed:
  1. `userId` (Ascending)
  2. `status` (Ascending)
  3. `createdAt` (Descending)

---

## 5. Firebase Authentication Setup

### 5.1: Enable Authentication Methods

1. Buka Firebase Console → Authentication
2. Klik tab **"Sign-in method"**
3. Enable **"Email/Password"**
4. (Opsional) Enable **"Google Sign-In"** untuk login dengan Google

### 5.2: Buat AuthProvider

File baru: `lib/providers/auth_provider.dart`

```dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  // Constructor - check if user already logged in
  AuthProvider() {
    _auth.authStateChanges().listen((firebase_auth.User? firebaseUser) {
      if (firebaseUser != null) {
        _loadUserData(firebaseUser.uid);
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  // Load user data from Firestore
  Future<void> _loadUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _currentUser = User.fromMap(doc.data()!);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  // Register with email and password
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Create user in Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      final user = User(
        id: credential.user!.uid,
        name: name,
        email: email,
        joinedDate: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.id).set(user.toMap());

      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _isLoading = false;
      
      // Handle specific error codes
      switch (e.code) {
        case 'weak-password':
          _errorMessage = 'Password terlalu lemah';
          break;
        case 'email-already-in-use':
          _errorMessage = 'Email sudah terdaftar';
          break;
        case 'invalid-email':
          _errorMessage = 'Format email tidak valid';
          break;
        default:
          _errorMessage = 'Registrasi gagal: ${e.message}';
      }
      
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Terjadi kesalahan: $e';
      notifyListeners();
      return false;
    }
  }

  // Login with email and password
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _loadUserData(credential.user!.uid);

      _isLoading = false;
      notifyListeners();
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _isLoading = false;
      
      switch (e.code) {
        case 'user-not-found':
          _errorMessage = 'Email tidak terdaftar';
          break;
        case 'wrong-password':
          _errorMessage = 'Password salah';
          break;
        case 'invalid-email':
          _errorMessage = 'Format email tidak valid';
          break;
        case 'user-disabled':
          _errorMessage = 'Akun telah dinonaktifkan';
          break;
        default:
          _errorMessage = 'Login gagal: ${e.message}';
      }
      
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Terjadi kesalahan: $e';
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
      _currentUser = null;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Logout gagal: $e';
      notifyListeners();
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? name,
    String? profileImageUrl,
  }) async {
    if (_currentUser == null) return false;

    try {
      _isLoading = true;
      notifyListeners();

      final updatedUser = _currentUser!.copyWith(
        name: name,
        profileImageUrl: profileImageUrl,
      );

      await _firestore
          .collection('users')
          .doc(_currentUser!.id)
          .update(updatedUser.toMap());

      _currentUser = updatedUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Update profile gagal: $e';
      notifyListeners();
      return false;
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
```

---

## 6. Firebase Storage Setup

### 6.1: Enable Firebase Storage

1. Buka Firebase Console → Storage
2. Klik **"Get started"**
3. Pilih **"Start in test mode"** (nanti kita ubah rules nya)
4. Pilih lokasi server (pilih yang dekat, misal: `asia-southeast1`)

### 6.2: Update BookProvider untuk Firebase

File: `lib/providers/book_provider.dart`

Akan saya buat di file terpisah di step berikutnya.

---

## 7. Security Rules

### 7.1: Firestore Security Rules

Di Firebase Console → Firestore Database → Rules:

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function to check if user is authenticated
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Helper function to check if user owns the document
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    // Users collection
    match /users/{userId} {
      // User can read their own data
      allow read: if isOwner(userId);
      
      // User can create their own document during registration
      allow create: if isOwner(userId);
      
      // User can update their own data
      allow update: if isOwner(userId);
      
      // User cannot delete their account (optional, bisa diubah)
      allow delete: if false;
    }
    
    // Books collection
    match /books/{bookId} {
      // User can only read their own books
      allow read: if isAuthenticated() && 
                     resource.data.userId == request.auth.uid;
      
      // User can create books with their userId
      allow create: if isAuthenticated() && 
                       request.resource.data.userId == request.auth.uid;
      
      // User can update their own books
      allow update: if isAuthenticated() && 
                       resource.data.userId == request.auth.uid;
      
      // User can delete their own books
      allow delete: if isAuthenticated() && 
                       resource.data.userId == request.auth.uid;
    }
  }
}
```

### 7.2: Firebase Storage Security Rules

Di Firebase Console → Storage → Rules:

```javascript
rules_version = '2';

service firebase.storage {
  match /b/{bucket}/o {
    
    // Profile images
    match /profile_images/{userId}/{fileName} {
      // Allow read for authenticated users
      allow read: if request.auth != null;
      
      // Allow write only for the owner and valid image files
      allow write: if request.auth != null && 
                      request.auth.uid == userId &&
                      request.resource.size < 5 * 1024 * 1024 && // Max 5MB
                      request.resource.contentType.matches('image/.*');
    }
    
    // Book cover images
    match /book_covers/{userId}/{fileName} {
      // Allow read for authenticated users
      allow read: if request.auth != null;
      
      // Allow write only for the owner and valid image files
      allow write: if request.auth != null && 
                      request.auth.uid == userId &&
                      request.resource.size < 10 * 1024 * 1024 && // Max 10MB
                      request.resource.contentType.matches('image/.*');
    }
  }
}
```

---

## 8. Testing

### 8.1: Test Authentication

1. Jalankan aplikasi
2. Coba register user baru
3. Cek di Firebase Console → Authentication → Users
4. Cek di Firebase Console → Firestore Database → users

### 8.2: Test Firestore

1. Login dengan user yang sudah dibuat
2. Tambah buku baru
3. Cek di Firebase Console → Firestore Database → books
4. Coba update dan delete buku

### 8.3: Test Storage (jika sudah implement upload image)

1. Upload gambar profile atau book cover
2. Cek di Firebase Console → Storage
3. Pastikan file tersimpan di folder yang benar

---

## 📱 Next Steps

Setelah setup Firebase selesai, kita perlu:

1. ✅ Update `BookProvider` untuk menggunakan Firestore
2. ✅ Update `UserProvider` untuk menggunakan Firestore
3. ✅ Integrate `AuthProvider` ke Login & Register Screen
4. ✅ Implement Image Upload ke Firebase Storage
5. ✅ Handle offline mode dengan Firestore cache
6. ✅ Add loading indicators
7. ✅ Add error handling

---

## 🆘 Troubleshooting

### Error: "Default FirebaseApp is not initialized"
**Solusi:** Pastikan `await Firebase.initializeApp()` dipanggil di `main()` sebelum `runApp()`

### Error: "google-services.json not found"
**Solusi:** 
1. Download ulang dari Firebase Console
2. Letakkan di `android/app/google-services.json`
3. Run `flutter clean` dan `flutter pub get`

### Error: "FirebaseException: PERMISSION_DENIED"
**Solusi:** Cek Security Rules di Firebase Console, pastikan rules sudah benar

### Build Error di Android
**Solusi:**
1. Update `minSdkVersion` di `android/app/build.gradle.kts` menjadi minimal `21`
2. Sync gradle files
3. Clean project: `flutter clean`

---

## 📚 Resources

- [Firebase Flutter Documentation](https://firebase.google.com/docs/flutter/setup)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)

---

**🔥 Setup Firebase untuk InkVoyage selesai!**

Lanjut ke file implementation berikutnya! 🚀
