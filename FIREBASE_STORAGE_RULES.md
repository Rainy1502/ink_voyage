# Firebase Storage Security Rules untuk InkVoyage

## 🖼️ Storage Rules yang Harus Diterapkan

Copy rules di bawah ini dan paste ke Firebase Console → Storage → Rules tab.

### Rules untuk Profile Images dan Book Covers

```javascript
rules_version = '2';

service firebase.storage {
  match /b/{bucket}/o {
    
    // Helper function: Check if user is authenticated
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Helper function: Check if file is an image
    function isImage() {
      return request.resource.contentType.matches('image/.*');
    }
    
    // Helper function: Check file size (max 5MB)
    function isValidSize() {
      return request.resource.size < 5 * 1024 * 1024;
    }
    
    // Profile images - each user can only access their own
    match /profile_images/{userId}/{imageId} {
      // Allow read if authenticated
      allow read: if isAuthenticated();
      
      // Allow write only if owner, is image, and valid size
      allow write: if isAuthenticated() 
                   && request.auth.uid == userId
                   && isImage()
                   && isValidSize();
      
      // Allow delete only if owner
      allow delete: if isAuthenticated() 
                    && request.auth.uid == userId;
    }
    
    // Book cover images - each user can only access their own
    match /book_covers/{userId}/{imageId} {
      // Allow read if authenticated
      allow read: if isAuthenticated();
      
      // Allow write only if owner, is image, and valid size
      allow write: if isAuthenticated() 
                   && request.auth.uid == userId
                   && isImage()
                   && isValidSize();
      
      // Allow delete only if owner
      allow delete: if isAuthenticated() 
                    && request.auth.uid == userId;
    }
  }
}
```

## 📋 Cara Menerapkan Rules

### Langkah 1: Buka Firebase Console
1. Buka [Firebase Console](https://console.firebase.google.com)
2. Pilih project **apk-inkvoyage**
3. Klik **Storage** di menu kiri
4. Klik tab **Rules** di bagian atas

### Langkah 2: Paste Rules
1. Hapus semua isi yang ada (biasanya test mode rules)
2. Copy rules di atas
3. Paste ke editor
4. Klik **Publish** button

### Langkah 3: Verifikasi
Setelah publish, kamu akan lihat status:
```
✅ Rules deployed successfully
```

## 🔍 Penjelasan Rules

### Profile Images (`/profile_images/{userId}/`)
- **Read**: Semua authenticated user bisa lihat profile images
- **Write**: Hanya owner bisa upload/update profile image mereka
- **Delete**: Hanya owner bisa delete image mereka
- **Validation**:
  - ✅ Harus image type (image/jpeg, image/png, dll)
  - ✅ Max 5MB size
  - ✅ UID harus match dengan path

### Book Covers (`/book_covers/{userId}/`)
- **Read**: Semua authenticated user bisa lihat book covers
- **Write**: Hanya owner bisa upload book cover
- **Delete**: Hanya owner bisa delete book cover
- **Validation**:
  - ✅ Harus image type
  - ✅ Max 5MB size
  - ✅ UID harus match dengan path

## 🔐 Keamanan yang Dijamin

### ✅ Protected
- User tidak bisa upload ke folder user lain
- File type validation (hanya images)
- File size limit (5MB max)
- Harus authenticated untuk akses

### ❌ Prevented
- Anonymous uploads
- Non-image file uploads
- Files > 5MB
- Cross-user folder access untuk write/delete

## 📁 Storage Structure

```
storage/
  profile_images/
    {userId}/
      {timestamp}_profile.jpg
      {timestamp}_profile.png
      
  book_covers/
    {userId}/
      {timestamp}_cover.jpg
      {timestamp}_cover.png
```

## 🧪 Test Rules

Kamu bisa test di Firebase Console → Storage → Rules → Playground:

### Test 1: Upload Profile Image (Should Allow)
```
Path: /profile_images/{your-uid}/1234567890_profile.jpg
Authenticated: Yes
UID: {your-uid}
File Type: image/jpeg
File Size: 1MB
Operation: create
Expected: ✅ Allow
```

### Test 2: Upload to Other User's Folder (Should Deny)
```
Path: /profile_images/{other-uid}/1234567890_profile.jpg
Authenticated: Yes
UID: {your-uid}
File Type: image/jpeg
File Size: 1MB
Operation: create
Expected: ❌ Deny
```

### Test 3: Upload Non-Image (Should Deny)
```
Path: /profile_images/{your-uid}/malware.exe
Authenticated: Yes
UID: {your-uid}
File Type: application/exe
File Size: 1MB
Operation: create
Expected: ❌ Deny
```

### Test 4: Upload Large File (Should Deny)
```
Path: /profile_images/{your-uid}/huge.jpg
Authenticated: Yes
UID: {your-uid}
File Type: image/jpeg
File Size: 10MB
Operation: create
Expected: ❌ Deny (exceeds 5MB limit)
```

## 📊 Supported Image Types

Rules menerima semua image MIME types:
- ✅ image/jpeg (.jpg, .jpeg)
- ✅ image/png (.png)
- ✅ image/gif (.gif)
- ✅ image/webp (.webp)
- ✅ image/bmp (.bmp)
- ✅ image/svg+xml (.svg)

## 💾 File Size Limits

| Type | Max Size | Reason |
|------|----------|--------|
| Profile Image | 5MB | Cukup untuk high-res photos |
| Book Cover | 5MB | Cukup untuk high-quality covers |

Jika butuh lebih besar, ubah di rules:
```javascript
function isValidSize() {
  return request.resource.size < 10 * 1024 * 1024; // 10MB
}
```

## ⚠️ Important Notes

1. **Test Mode vs Production**
   - Test mode: `allow read, write: if true;` (JANGAN PAKAI!)
   - Production: Gunakan rules di atas

2. **Setelah Deploy Rules**
   - Test upload profile image di app
   - Test upload book cover saat add book
   - Coba dengan file > 5MB (should fail)
   - Coba dengan non-image file (should fail)

3. **Jika Ada Error "Permission Denied"**
   - Cek user sudah login
   - Cek userId di path sama dengan auth.uid
   - Cek file type adalah image
   - Cek file size < 5MB

4. **Cleanup Old Images**
   - Saat user update profile image, delete old image
   - Saat user delete book, delete book cover
   - Sudah implemented di `StorageService`

## 🚀 Integration dengan StorageService

File `lib/services/storage_service.dart` sudah compatible dengan rules ini:

```dart
// Upload profile image
// Path: /profile_images/{userId}/{timestamp}_profile.ext
await storageService.uploadProfileImage(File imageFile);

// Upload book cover  
// Path: /book_covers/{userId}/{timestamp}_cover.ext
await storageService.uploadBookCover(File imageFile);

// Delete images
await storageService.deleteProfileImage(String imageUrl);
await storageService.deleteBookCover(String imageUrl);
```

## 🔄 URL Format Returned

Setelah upload, kamu akan dapat URL format:
```
https://firebasestorage.googleapis.com/v0/b/apk-inkvoyage.appspot.com/o/profile_images%2F{userId}%2F{timestamp}_profile.jpg?alt=media&token={token}
```

URL ini bisa langsung dipakai di:
- User model: `profileImageUrl` field
- Book model: `imageUrl` field
- Image.network() widget

---

**Status**: 🔴 BELUM DEPLOY (masih test mode)  
**Action Required**: Deploy rules production di atas SEKARANG!

## 📝 Checklist

- [ ] Copy Storage Rules dari file ini
- [ ] Paste ke Firebase Console → Storage → Rules
- [ ] Klik Publish
- [ ] Test upload profile image
- [ ] Test upload book cover
- [ ] Test file size validation
- [ ] Test cross-user prevention
