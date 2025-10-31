# ✅ Firebase Integration Checklist - InkVoyage

## 📦 Files Created

### ✅ Documentation
- [x] `FIREBASE_SETUP_GUIDE.md` - Complete setup guide
- [x] `FIREBASE_BOOK_PROVIDER.md` - BookProvider implementation guide
- [x] `FIREBASE_INTEGRATION_CHECKLIST.md` - This file

### ✅ Code Files
- [x] `lib/providers/auth_provider.dart` - Authentication provider
- [x] `lib/services/storage_service.dart` - Firebase Storage service

---

## 🚀 Implementation Steps

### Phase 1: Firebase Console Setup ⏳

- [ ] **1.1** Create Firebase project `ink-voyage`
- [ ] **1.2** Register Android app
  - [ ] Download `google-services.json`
  - [ ] Place in `android/app/google-services.json`
- [ ] **1.3** (Optional) Register iOS app
  - [ ] Download `GoogleService-Info.plist`
  - [ ] Place in `ios/Runner/GoogleService-Info.plist`
- [ ] **1.4** Enable Firebase Authentication
  - [ ] Enable Email/Password method
- [ ] **1.5** Create Firestore Database
  - [ ] Start in test mode
  - [ ] Choose location: `asia-southeast1`
- [ ] **1.6** Enable Firebase Storage
  - [ ] Start in test mode
  - [ ] Choose location: `asia-southeast1`

---

### Phase 2: Dependencies Installation ⏳

- [ ] **2.1** Update `pubspec.yaml` (see guide)
- [ ] **2.2** Run `flutter pub get`
- [ ] **2.3** Verify no errors

**Dependencies to add:**
```yaml
firebase_core: ^3.6.0
firebase_auth: ^5.3.1
cloud_firestore: ^5.4.4
firebase_storage: ^12.3.4
```

---

### Phase 3: Android Configuration ⏳

- [ ] **3.1** Update `android/build.gradle.kts`
  - [ ] Add google-services classpath
- [ ] **3.2** Update `android/app/build.gradle.kts`
  - [ ] Apply google-services plugin
  - [ ] Add Firebase BOM dependency
- [ ] **3.3** Update `minSdkVersion` to 21 (if needed)
- [ ] **3.4** Sync Gradle files
- [ ] **3.5** Run `flutter clean`

---

### Phase 4: Main.dart Updates ⏳

- [ ] **4.1** Import `firebase_core`
- [ ] **4.2** Add `WidgetsFlutterBinding.ensureInitialized()`
- [ ] **4.3** Add `await Firebase.initializeApp()`
- [ ] **4.4** Add `AuthProvider` to MultiProvider
- [ ] **4.5** Test app runs without errors

**Reference code:**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}
```

---

### Phase 5: BookProvider Migration ⏳

- [ ] **5.1** Backup current `book_provider.dart`
- [ ] **5.2** Replace with Firebase version (see FIREBASE_BOOK_PROVIDER.md)
- [ ] **5.3** Test compile (errors expected until Phase 2 done)
- [ ] **5.4** Update all screens using BookProvider
  - [ ] Add loading indicators
  - [ ] Add error handling
  - [ ] Add pull-to-refresh

**Files to update:**
- `lib/screens/book_list_screen.dart`
- `lib/screens/book_detail_screen.dart`
- `lib/screens/add_book_upload_screen.dart`
- `lib/screens/add_book_url_screen.dart`
- `lib/screens/edit_book_screen.dart`
- `lib/screens/update_progress_screen.dart`
- `lib/screens/home_screen.dart`

---

### Phase 6: Authentication Integration ⏳

#### Login Screen
- [ ] **6.1** Import `auth_provider.dart`
- [ ] **6.2** Get AuthProvider instance
- [ ] **6.3** Call `authProvider.login()`
- [ ] **6.4** Handle loading state
- [ ] **6.5** Handle errors
- [ ] **6.6** Navigate on success

**Example:**
```dart
final authProvider = Provider.of<AuthProvider>(context, listen: false);

if (authProvider.isLoading) {
  // Show loading indicator
}

final success = await authProvider.login(
  email: emailController.text,
  password: passwordController.text,
);

if (success) {
  // Navigate to home
} else {
  // Show error: authProvider.errorMessage
}
```

#### Register Screen
- [ ] **6.7** Import `auth_provider.dart`
- [ ] **6.8** Get AuthProvider instance
- [ ] **6.9** Call `authProvider.register()`
- [ ] **6.10** Handle loading state
- [ ] **6.11** Handle errors
- [ ] **6.12** Navigate on success

#### Profile Screen
- [ ] **6.13** Get user from `authProvider.currentUser`
- [ ] **6.14** Update logout to use `authProvider.logout()`
- [ ] **6.15** Handle profile update

---

### Phase 7: Storage Integration ⏳

#### Add Book Upload Screen
- [ ] **7.1** Import `storage_service.dart`
- [ ] **7.2** Create StorageService instance
- [ ] **7.3** Upload image using `uploadBookCover()`
- [ ] **7.4** Get download URL
- [ ] **7.5** Save URL to book model
- [ ] **7.6** Add progress indicator

**Example:**
```dart
final storageService = StorageService();
final imageUrl = await storageService.uploadBookCover(imageFile);

if (imageUrl != null) {
  // Use imageUrl in book model
}
```

#### Profile Image Upload
- [ ] **7.7** Add image picker for profile
- [ ] **7.8** Upload using `uploadProfileImage()`
- [ ] **7.9** Update user profile with new URL
- [ ] **7.10** Show preview

---

### Phase 8: Security Rules ⏳

#### Firestore Rules
- [ ] **8.1** Copy rules from guide
- [ ] **8.2** Paste in Firebase Console → Firestore → Rules
- [ ] **8.3** Publish rules
- [ ] **8.4** Test authentication works

#### Storage Rules
- [ ] **8.5** Copy rules from guide
- [ ] **8.6** Paste in Firebase Console → Storage → Rules
- [ ] **8.7** Publish rules
- [ ] **8.8** Test upload works

---

### Phase 9: Testing ⏳

#### Authentication Tests
- [ ] **9.1** Test register new user
  - [ ] Check Firebase Console → Authentication → Users
  - [ ] Check Firestore → users collection
- [ ] **9.2** Test login with correct credentials
- [ ] **9.3** Test login with wrong credentials
- [ ] **9.4** Test logout
- [ ] **9.5** Test auto-login (close & reopen app)

#### Book CRUD Tests
- [ ] **9.6** Test add new book
  - [ ] Check Firestore → books collection
  - [ ] Verify userId field exists
- [ ] **9.7** Test update book
  - [ ] Verify updatedAt timestamp
- [ ] **9.8** Test delete book
  - [ ] Verify deleted from Firestore
- [ ] **9.9** Test update progress
- [ ] **9.10** Test update status
- [ ] **9.11** Test add rating
- [ ] **9.12** Test add notes

#### Storage Tests
- [ ] **9.13** Test book cover upload
  - [ ] Check Firebase Console → Storage → book_covers
- [ ] **9.14** Test profile image upload
  - [ ] Check Firebase Console → Storage → profile_images
- [ ] **9.15** Test image delete

#### Multi-User Tests
- [ ] **9.16** Create 2 different users
- [ ] **9.17** Add books to User A
- [ ] **9.18** Login as User B
- [ ] **9.19** Verify User B can't see User A's books
- [ ] **9.20** Verify security rules working

---

### Phase 10: Error Handling & UX ⏳

- [ ] **10.1** Add try-catch in all Firebase calls
- [ ] **10.2** Show loading indicators
- [ ] **10.3** Show error messages
- [ ] **10.4** Add pull-to-refresh on book list
- [ ] **10.5** Add retry buttons on errors
- [ ] **10.6** Handle offline mode
- [ ] **10.7** Add empty states
- [ ] **10.8** Add success messages

---

### Phase 11: Optimization ⏳

- [ ] **11.1** Enable Firestore offline persistence
- [ ] **11.2** Add caching for images
- [ ] **11.3** Optimize Firestore queries
- [ ] **11.4** Add indexes for complex queries
- [ ] **11.5** Compress images before upload
- [ ] **11.6** Add pagination for book list (if many books)

**Offline persistence:**
```dart
// In main.dart after Firebase.initializeApp()
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

---

## 📁 File Structure After Implementation

```
lib/
├── main.dart (✅ Updated with Firebase init)
├── models/
│   ├── book_model.dart (existing)
│   └── user_model.dart (existing)
├── providers/
│   ├── auth_provider.dart (✅ NEW)
│   ├── book_provider.dart (✅ Updated with Firebase)
│   ├── theme_provider.dart (existing)
│   └── user_provider.dart (existing)
├── services/
│   └── storage_service.dart (✅ NEW)
├── screens/
│   ├── login_screen.dart (⏳ Need update)
│   ├── register_screen.dart (⏳ Need update)
│   ├── profile_screen.dart (⏳ Need update)
│   ├── book_list_screen.dart (⏳ Need update)
│   ├── add_book_upload_screen.dart (⏳ Need update)
│   └── ... (other screens)
└── ...

android/
├── app/
│   ├── build.gradle.kts (⏳ Need update)
│   └── google-services.json (⏳ Need to add)
└── build.gradle.kts (⏳ Need update)
```

---

## 🎯 Quick Start Command

After completing Phase 1 & 2, run these commands:

```bash
# Clean project
flutter clean

# Get dependencies
flutter pub get

# Check for issues
flutter analyze

# Run app
flutter run
```

---

## 🆘 Common Issues & Solutions

### Issue: "Default FirebaseApp is not initialized"
**Solution:** Add `await Firebase.initializeApp()` in `main()` before `runApp()`

### Issue: "google-services.json not found"
**Solution:** 
1. Download from Firebase Console
2. Place in `android/app/google-services.json`
3. Run `flutter clean`

### Issue: "PERMISSION_DENIED" in Firestore
**Solution:** 
1. Check Security Rules in Firebase Console
2. Make sure user is authenticated
3. Check userId matches in rules

### Issue: Build fails on Android
**Solution:**
1. Update `minSdkVersion` to 21
2. Add google-services plugin
3. Sync gradle files
4. Run `flutter clean`

### Issue: Images not uploading
**Solution:**
1. Check Storage Rules
2. Verify user is authenticated
3. Check file size < 10MB
4. Check internet connection

---

## 📊 Progress Tracking

**Overall Progress:** 0 / 11 Phases Complete

- [ ] Phase 1: Firebase Console Setup (0/6)
- [ ] Phase 2: Dependencies (0/3)
- [ ] Phase 3: Android Config (0/5)
- [ ] Phase 4: Main.dart (0/5)
- [ ] Phase 5: BookProvider (0/4)
- [ ] Phase 6: Authentication (0/15)
- [ ] Phase 7: Storage (0/10)
- [ ] Phase 8: Security Rules (0/8)
- [ ] Phase 9: Testing (0/20)
- [ ] Phase 10: Error Handling (0/8)
- [ ] Phase 11: Optimization (0/6)

**Total Tasks:** 90

---

## 📞 Need Help?

Jika ada kesulitan di step manapun:

1. **Check Firebase Console** untuk error messages
2. **Check logs** di terminal Flutter
3. **Read documentation** di FIREBASE_SETUP_GUIDE.md
4. **Debug step by step** - jangan skip steps!

---

**🔥 Let's integrate Firebase! Mulai dari Phase 1! 🚀**
