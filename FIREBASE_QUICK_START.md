# 🚀 Firebase Quick Start - InkVoyage

## TL;DR - Langkah Cepat

Ikuti step ini secara **berurutan**:

---

## ⚡ Step 1: Firebase Console (5 menit)

1. Buka https://console.firebase.google.com/
2. Klik "Add project" → nama: `ink-voyage`
3. Klik icon Android → package: `com.example.ink_voyage`
4. Download `google-services.json` → taruh di `android/app/`
5. Enable **Authentication** → Email/Password
6. Create **Firestore Database** → Test mode → Asia Southeast
7. Enable **Storage** → Test mode → Asia Southeast

✅ **Done!** Firebase project ready!

---

## ⚡ Step 2: Update pubspec.yaml (2 menit)

Tambahkan di bagian `dependencies:`:

```yaml
  # Firebase
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.1
  cloud_firestore: ^5.4.4
  firebase_storage: ^12.3.4
```

Run:
```bash
flutter pub get
```

---

## ⚡ Step 3: Android Configuration (3 menit)

### File: `android/build.gradle.kts`

Tambahkan di bagian atas (sebelum `plugins`):

```kotlin
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.2")
    }
}
```

### File: `android/app/build.gradle.kts`

**Di bagian paling bawah**, tambahkan:

```kotlin
apply(plugin = "com.google.gms.google-services")
```

**Di bagian `dependencies`**, tambahkan:

```kotlin
dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.5.1"))
    implementation("com.google.firebase:firebase-analytics")
}
```

**Di bagian `defaultConfig`**, pastikan `minSdk = 21`:

```kotlin
android {
    defaultConfig {
        minSdk = 21  // Update ini jika masih 16
    }
}
```

---

## ⚡ Step 4: Update main.dart (2 menit)

Ganti isi `lib/main.dart` dengan:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Import providers
import 'providers/book_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/user_provider.dart';
import 'providers/auth_provider.dart';

// Import themes
import 'themes/light_theme.dart';

// Import screens
import 'screens/splash_screen.dart';

void main() async {
  // Initialize Flutter binding
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
        ChangeNotifierProvider(create: (_) => AuthProvider()),
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

## ⚡ Step 5: Test Build (2 menit)

```bash
flutter clean
flutter pub get
flutter run
```

**Expected:**
- App compiles successfully ✅
- No Firebase errors ✅
- App runs normally ✅

Jika ada error, cek bagian Troubleshooting di bawah.

---

## ⚡ Step 6: Security Rules (2 menit)

### Firestore Rules

Firebase Console → Firestore Database → Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    match /users/{userId} {
      allow read, create, update: if isOwner(userId);
      allow delete: if false;
    }
    
    match /books/{bookId} {
      allow read: if isAuthenticated() && 
                     resource.data.userId == request.auth.uid;
      allow create: if isAuthenticated() && 
                       request.resource.data.userId == request.auth.uid;
      allow update, delete: if isAuthenticated() && 
                               resource.data.userId == request.auth.uid;
    }
  }
}
```

Klik **Publish**

### Storage Rules

Firebase Console → Storage → Rules:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /profile_images/{userId}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                      request.auth.uid == userId &&
                      request.resource.size < 5 * 1024 * 1024;
    }
    
    match /book_covers/{userId}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                      request.auth.uid == userId &&
                      request.resource.size < 10 * 1024 * 1024;
    }
  }
}
```

Klik **Publish**

---

## ⚡ Step 7: Test Basic Features (5 menit)

✅ **Test Register:**
1. Buka app
2. Pergi ke Register screen
3. Register user baru
4. Check Firebase Console → Authentication → Users

✅ **Test Login:**
1. Logout
2. Login dengan credentials yang tadi
3. Harusnya berhasil

✅ **Test Books (after implementing BookProvider):**
1. Add a book
2. Check Firebase Console → Firestore → books
3. Update book
4. Delete book

---

## 🆘 Troubleshooting

### Error: "Default FirebaseApp is not initialized"

**Penyebab:** Firebase belum di-initialize

**Fix:**
```dart
// Di main.dart, pastikan ada ini:
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();  // ← INI PENTING!
  runApp(const MyApp());
}
```

---

### Error: "google-services.json not found"

**Penyebab:** File belum di-download atau salah lokasi

**Fix:**
1. Download dari Firebase Console → Project Settings → Your apps
2. Taruh EXACTLY di: `android/app/google-services.json`
3. Run: `flutter clean && flutter pub get`

---

### Error: Build failed - "Could not resolve com.google.firebase"

**Penyebab:** Gradle config salah

**Fix:**
1. Check `android/build.gradle.kts` ada google-services classpath
2. Check `android/app/build.gradle.kts` ada google-services plugin
3. Run: `cd android && ./gradlew clean` (or `gradlew.bat clean` di Windows)
4. Run: `flutter clean && flutter pub get`

---

### Error: "PERMISSION_DENIED" di Firestore

**Penyebab:** Security rules belum di-setup atau user belum login

**Fix:**
1. Check user sudah login: `authProvider.isAuthenticated == true`
2. Check Security Rules di Firebase Console sudah di-publish
3. Check `userId` field ada di book documents

---

### Error: Stuck at "Running Gradle task 'assembleDebug'"

**Penyebab:** First build Android dengan Firebase, download dependencies

**Fix:**
- **Normal!** First build bisa 5-10 menit
- Tunggu sampai selesai
- Next build akan lebih cepat

---

### Warning: "Unverified API"

**Penyebab:** Firebase Auth domain belum verified

**Fix:**
- **Aman!** Ini cuma warning
- Bisa diabaikan untuk development
- Production nanti perlu verify domain

---

## 📋 Verification Checklist

Setelah semua step selesai, verify:

- [ ] App compile tanpa error
- [ ] Firebase initialized di startup
- [ ] No "FirebaseApp not initialized" error
- [ ] AuthProvider available di app
- [ ] BookProvider available di app
- [ ] Can run app normally
- [ ] Firebase Console shows project
- [ ] Firestore database created
- [ ] Storage bucket created
- [ ] Authentication enabled
- [ ] Security rules published

---

## 🎯 What's Next?

Setelah basic setup selesai:

1. **Update BookProvider** - Integrate dengan Firestore
   - Read: `FIREBASE_BOOK_PROVIDER.md`
   
2. **Update Login Screen** - Integrate dengan AuthProvider
   - Add loading indicators
   - Handle errors
   
3. **Update Register Screen** - Integrate dengan AuthProvider
   - Add validation
   - Handle errors

4. **Update Book Screens** - Add Firebase functionality
   - Add/Edit/Delete books
   - Upload images to Storage

5. **Test Everything!**
   - Register new users
   - Add books
   - Update progress
   - Upload images

---

## 📚 Full Documentation

Untuk detail lengkap, baca:
- `FIREBASE_SETUP_GUIDE.md` - Complete setup guide
- `FIREBASE_BOOK_PROVIDER.md` - BookProvider implementation
- `FIREBASE_INTEGRATION_CHECKLIST.md` - Detailed checklist

---

## 💡 Pro Tips

1. **Always check Firebase Console** untuk verify data masuk
2. **Use Debug Logs** - `debugPrint()` untuk track issues
3. **Test incrementally** - jangan coding banyak tanpa test
4. **Read error messages** carefully - biasanya jelas masalahnya
5. **Clear cache often** - `flutter clean` adalah teman kamu

---

**🔥 Firebase setup dalam 20 menit! Let's go! 🚀**

**Questions? Check:**
- FIREBASE_SETUP_GUIDE.md (detailed)
- Firebase Console error messages
- Flutter terminal logs

**Good luck! 🎉**
