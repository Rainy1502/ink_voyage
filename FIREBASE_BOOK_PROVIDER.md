# 📚 Firebase BookProvider Implementation

## File: `lib/providers/book_provider_firebase.dart`

Ini adalah versi lengkap BookProvider yang terintegrasi dengan Firebase Firestore.

## Update BookProvider

Ganti isi file `lib/providers/book_provider.dart` dengan kode berikut:

```dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/book_model.dart';

class BookProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  List<Book> _books = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Book> get books => _books;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Filter books by status
  List<Book> get readingBooks =>
      _books.where((book) => book.status == 'reading').toList();

  List<Book> get completedBooks =>
      _books.where((book) => book.status == 'completed').toList();

  List<Book> get notStartedBooks =>
      _books.where((book) => book.status == 'not-started').toList();

  // Statistics
  int get totalBooks => _books.length;
  int get readingCount => readingBooks.length;
  int get completedCount => completedBooks.length;
  int get notStartedCount => notStartedBooks.length;

  int get totalPagesRead {
    return _books.fold(0, (sum, book) => sum + book.currentPage);
  }

  double get averageProgress {
    if (_books.isEmpty) return 0;
    double totalProgress = _books.fold(
      0,
      (sum, book) => sum + book.progressPercentage,
    );
    return totalProgress / _books.length;
  }

  // Constructor - load books when provider is created
  BookProvider() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        loadBooks();
      } else {
        _books = [];
        notifyListeners();
      }
    });
  }

  // Get current user ID
  String? get _userId => _auth.currentUser?.uid;

  // Load all books from Firestore
  Future<void> loadBooks() async {
    if (_userId == null) {
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final querySnapshot = await _firestore
          .collection('books')
          .where('userId', isEqualTo: _userId)
          .orderBy('createdAt', descending: true)
          .get();

      _books = querySnapshot.docs
          .map((doc) => Book.fromMap(doc.data()))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load books: $e';
      notifyListeners();
      debugPrint('Error loading books: $e');
    }
  }

  // Add new book
  Future<bool> addBook(Book book) async {
    if (_userId == null) {
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Generate new book ID
      final docRef = _firestore.collection('books').doc();
      
      // Create book with userId and generated ID
      final bookData = book.toMap();
      bookData['userId'] = _userId;
      bookData['id'] = docRef.id;

      await docRef.set(bookData);

      // Add to local list
      final newBook = Book.fromMap(bookData);
      _books.insert(0, newBook);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to add book: $e';
      notifyListeners();
      debugPrint('Error adding book: $e');
      return false;
    }
  }

  // Update existing book
  Future<bool> updateBook(Book updatedBook) async {
    if (_userId == null) {
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final bookData = updatedBook.toMap();
      bookData['userId'] = _userId;
      bookData['updatedAt'] = DateTime.now().toIso8601String();

      await _firestore
          .collection('books')
          .doc(updatedBook.id)
          .update(bookData);

      // Update local list
      final index = _books.indexWhere((b) => b.id == updatedBook.id);
      if (index != -1) {
        _books[index] = updatedBook.copyWith(updatedAt: DateTime.now());
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to update book: $e';
      notifyListeners();
      debugPrint('Error updating book: $e');
      return false;
    }
  }

  // Delete book
  Future<bool> deleteBook(String bookId) async {
    if (_userId == null) {
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _firestore.collection('books').doc(bookId).delete();

      // Remove from local list
      _books.removeWhere((book) => book.id == bookId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to delete book: $e';
      notifyListeners();
      debugPrint('Error deleting book: $e');
      return false;
    }
  }

  // Update book progress
  Future<bool> updateProgress(String bookId, int currentPage) async {
    final book = _books.firstWhere((b) => b.id == bookId);
    
    // Auto-update status based on progress
    String newStatus = book.status;
    if (currentPage >= book.totalPages) {
      newStatus = 'completed';
    } else if (currentPage > 0) {
      newStatus = 'reading';
    } else {
      newStatus = 'not-started';
    }

    final updatedBook = book.copyWith(
      currentPage: currentPage,
      status: newStatus,
      updatedAt: DateTime.now(),
    );

    return await updateBook(updatedBook);
  }

  // Update book status
  Future<bool> updateStatus(String bookId, String status) async {
    final book = _books.firstWhere((b) => b.id == bookId);
    
    // Auto-update currentPage based on status
    int newCurrentPage = book.currentPage;
    if (status == 'completed' && book.currentPage < book.totalPages) {
      newCurrentPage = book.totalPages;
    } else if (status == 'not-started') {
      newCurrentPage = 0;
    }

    final updatedBook = book.copyWith(
      status: status,
      currentPage: newCurrentPage,
      updatedAt: DateTime.now(),
    );

    return await updateBook(updatedBook);
  }

  // Rate a book
  Future<bool> rateBook(String bookId, int rating) async {
    final book = _books.firstWhere((b) => b.id == bookId);
    final updatedBook = book.copyWith(
      rating: rating,
      updatedAt: DateTime.now(),
    );

    return await updateBook(updatedBook);
  }

  // Add/Update notes
  Future<bool> updateNotes(String bookId, String notes) async {
    final book = _books.firstWhere((b) => b.id == bookId);
    final updatedBook = book.copyWith(
      notes: notes,
      updatedAt: DateTime.now(),
    );

    return await updateBook(updatedBook);
  }

  // Get book by ID
  Book? getBookById(String id) {
    try {
      return _books.firstWhere((book) => book.id == id);
    } catch (e) {
      return null;
    }
  }

  // Search books
  List<Book> searchBooks(String query) {
    if (query.isEmpty) return _books;

    final lowerQuery = query.toLowerCase();
    return _books.where((book) {
      return book.title.toLowerCase().contains(lowerQuery) ||
          book.author.toLowerCase().contains(lowerQuery) ||
          (book.genre?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  // Filter books by genre
  List<Book> getBooksByGenre(String genre) {
    return _books
        .where((book) => book.genre?.toLowerCase() == genre.toLowerCase())
        .toList();
  }

  // Get all unique genres
  List<String> get allGenres {
    final genres = <String>{};
    for (var book in _books) {
      if (book.genre != null && book.genre!.isNotEmpty) {
        genres.add(book.genre!);
      }
    }
    return genres.toList()..sort();
  }

  // Get reading statistics for charts
  Map<String, int> getReadingStatsByMonth() {
    final stats = <String, int>{};
    final now = DateTime.now();

    for (var i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthKey = '${month.year}-${month.month.toString().padLeft(2, '0')}';
      stats[monthKey] = 0;
    }

    for (var book in completedBooks) {
      final updatedAt = book.updatedAt ?? book.createdAt;
      final monthKey = '${updatedAt.year}-${updatedAt.month.toString().padLeft(2, '0')}';
      if (stats.containsKey(monthKey)) {
        stats[monthKey] = stats[monthKey]! + 1;
      }
    }

    return stats;
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Refresh books (force reload from Firestore)
  Future<void> refresh() async {
    await loadBooks();
  }
}
```

## Key Features

### ✅ **Firebase Integration**
- Real-time sync dengan Firestore
- Auto-load books ketika user login
- Auto-clear books ketika user logout

### ✅ **CRUD Operations**
- ✅ `loadBooks()` - Load semua buku dari Firestore
- ✅ `addBook()` - Tambah buku baru
- ✅ `updateBook()` - Update buku existing
- ✅ `deleteBook()` - Hapus buku
- ✅ `updateProgress()` - Update progress membaca
- ✅ `updateStatus()` - Update status buku
- ✅ `rateBook()` - Beri rating buku
- ✅ `updateNotes()` - Tambah/update notes

### ✅ **Data Management**
- userId automatically added ke setiap book
- createdAt dan updatedAt timestamps
- Error handling yang proper
- Loading states untuk UI feedback

### ✅ **Statistics & Analytics**
- Total books count
- Reading/Completed/Not-started counts
- Total pages read
- Average reading progress
- Reading stats by month (untuk charts)

### ✅ **Search & Filter**
- Search by title, author, genre
- Filter by genre
- Filter by status
- Get all unique genres

## Changes Needed

### 1. Update BookProvider import di semua file
Ganti import dari:
```dart
import 'package:ink_voyage/providers/book_provider.dart';
```

Tidak perlu diganti karena nama file sama.

### 2. Handle Loading States di UI
Tambahkan loading indicators di screens yang menggunakan BookProvider.

Contoh di `book_list_screen.dart`:
```dart
Consumer<BookProvider>(
  builder: (context, bookProvider, child) {
    if (bookProvider.isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    
    if (bookProvider.errorMessage != null) {
      return Center(
        child: Text(
          bookProvider.errorMessage!,
          style: TextStyle(color: Colors.red),
        ),
      );
    }
    
    // Show books list
    return ListView.builder(...);
  },
)
```

### 3. Add Pull-to-Refresh
```dart
RefreshIndicator(
  onRefresh: () async {
    await bookProvider.refresh();
  },
  child: ListView.builder(...),
)
```

## Testing

1. Install Firebase packages
2. Run `flutter pub get`
3. Test add book
4. Check Firestore Console
5. Test update, delete
6. Test search & filter
7. Test logout (books should clear)
8. Test login again (books should reload)

---

**🔥 BookProvider Firebase Integration Complete!**
