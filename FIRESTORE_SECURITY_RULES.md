# Firestore Security Rules untuk InkVoyage

## 🔒 Security Rules yang Harus Diterapkan

Copy rules di bawah ini dan paste ke Firebase Console → Firestore Database → Rules tab.

### Rules untuk Users dan Books Collections

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function: Check if user is authenticated
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Helper function: Check if user is owner
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    // Users collection rules
    match /users/{userId} {
      // Allow read if authenticated and is owner
      allow read: if isOwner(userId);
      
      // Allow create only during registration
      allow create: if isAuthenticated() && request.auth.uid == userId;
      
      // Allow update only if owner
      allow update: if isOwner(userId);
      
      // Don't allow delete
      allow delete: if false;
      
      // Books subcollection for each user
      match /books/{bookId} {
        // Allow read if owner
        allow read: if isOwner(userId);
        
        // Allow create if owner
        allow create: if isOwner(userId) 
                      && request.resource.data.keys().hasAll(['title', 'author', 'imageUrl', 'totalPages', 'currentPage', 'status', 'createdAt']);
        
        // Allow update if owner
        allow update: if isOwner(userId);
        
        // Allow delete if owner
        allow delete: if isOwner(userId);
      }
    }
  }
}
```

## 📋 Cara Menerapkan Rules

### Langkah 1: Buka Firebase Console
1. Buka [Firebase Console](https://console.firebase.google.com)
2. Pilih project **apk-inkvoyage**
3. Klik **Firestore Database** di menu kiri
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

### Users Collection
- **Read**: Hanya owner bisa baca data mereka sendiri
- **Create**: Hanya saat registration dengan UID yang match
- **Update**: Hanya owner bisa update profile mereka
- **Delete**: Tidak diizinkan (untuk data safety)

### Books Subcollection
- **Read**: User hanya bisa baca buku mereka sendiri
- **Create**: User hanya bisa tambah buku ke collection mereka
  - Harus punya field wajib: title, author, imageUrl, totalPages, currentPage, status, createdAt
- **Update**: User hanya bisa update buku mereka sendiri
- **Delete**: User hanya bisa hapus buku mereka sendiri

## 🔐 Keamanan yang Dijamin

### ✅ Protected
- User A tidak bisa baca buku User B
- User tidak bisa hapus data user lain
- Harus login untuk akses semua data
- Validasi field wajib saat create book

### ❌ Prevented
- Anonymous access (harus login)
- Cross-user data access
- Permanent user deletion
- Invalid data creation (missing required fields)

## 🧪 Test Rules

Kamu bisa test rules di Firebase Console:

1. Klik tab **Rules** → **Playground** button
2. Test case untuk **Read**:
   ```
   Location: /users/{your-uid}/books/{book-id}
   Authenticated: Yes
   UID: {your-uid}
   Operation: get
   Expected: ✅ Allow
   ```

3. Test case untuk **Cross-user access**:
   ```
   Location: /users/{other-uid}/books/{book-id}
   Authenticated: Yes
   UID: {your-uid}
   Operation: get
   Expected: ❌ Deny
   ```

## 📊 Database Structure yang Dijaga

```
users/
  {userId}/
    - id: string
    - name: string
    - email: string
    - joinedDate: timestamp
    - profileImageUrl: string? (optional)
    
    books/
      {bookId}/
        - title: string (required)
        - author: string (required)
        - imageUrl: string (required)
        - totalPages: number (required)
        - currentPage: number (required)
        - status: string (required)
        - createdAt: timestamp (required)
        - updatedAt: timestamp (optional)
        - genre: string (optional)
        - rating: number (optional)
        - notes: string (optional)
```

## ⚠️ Important Notes

1. **Test Mode vs Production**
   - Test mode: `allow read, write: if true;` (JANGAN PAKAI INI!)
   - Production: Gunakan rules di atas

2. **Setelah Deploy Rules**
   - Test app dengan login berbeda
   - Pastikan user tidak bisa lihat data user lain
   - Coba add/update/delete books

3. **Jika Ada Error "Permission Denied"**
   - Cek user sudah login (FirebaseAuth.currentUser != null)
   - Cek userId di path matches dengan auth.uid
   - Cek semua required fields ada saat create

## 🚀 Next Steps Setelah Deploy Rules

1. ✅ Test registration dan login
2. ✅ Test add book
3. ✅ Test update progress
4. ✅ Test delete book
5. ✅ Logout dan test dengan user berbeda
6. ✅ Pastikan data terisolasi per user

---

**Status**: 🔴 BELUM DEPLOY (masih test mode)  
**Action Required**: Deploy rules production di atas SEKARANG!
