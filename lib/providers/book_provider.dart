import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book_model.dart';

class BookProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  List<Book> _books = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Book> get books => _books;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get books by status
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
  int get totalPagesRead =>
      _books.fold(0, (total, book) => total + book.currentPage);

  // Initialize and load books from Firestore
  Future<void> loadBooks() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      _books = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('books')
          .orderBy('createdAt', descending: true)
          .get();

      _books = snapshot.docs
          .map((doc) => Book.fromMap({...doc.data(), 'id': doc.id}))
          .toList();

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Gagal memuat buku: $e';
      debugPrint('Error loading books: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Listen to real-time updates from Firestore
  void startListening() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    _firestore
        .collection('users')
        .doc(userId)
        .collection('books')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            _books = snapshot.docs
                .map((doc) => Book.fromMap({...doc.data(), 'id': doc.id}))
                .toList();
            notifyListeners();
          },
          onError: (error) {
            _errorMessage = 'Error listening to updates: $error';
            debugPrint('Error listening to books: $error');
            notifyListeners();
          },
        );
  }

  // Add a new book
  Future<bool> addBook(Book book) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      _errorMessage = 'User tidak terautentikasi';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Create book document in Firestore
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('books')
          .add(book.toMap());

      // Add to local list with Firestore-generated ID
      final bookWithId = book.copyWith(id: docRef.id);
      _books.insert(0, bookWithId);

      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menambah buku: $e';
      debugPrint('Error adding book: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update existing book
  Future<bool> updateBook(String id, Book updatedBook) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      _errorMessage = 'User tidak terautentikasi';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Update in Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('books')
          .doc(id)
          .update(updatedBook.toMap());

      // Update local list
      final index = _books.indexWhere((book) => book.id == id);
      if (index != -1) {
        _books[index] = updatedBook;
      }

      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Gagal mengupdate buku: $e';
      debugPrint('Error updating book: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete book
  Future<bool> deleteBook(String id) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      _errorMessage = 'User tidak terautentikasi';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Delete from Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('books')
          .doc(id)
          .delete();

      // Delete from local list
      _books.removeWhere((book) => book.id == id);

      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menghapus buku: $e';
      debugPrint('Error deleting book: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update reading progress
  Future<bool> updateProgress(
    String id,
    int currentPage, {
    int? rating,
    String? notes,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      _errorMessage = 'User tidak terautentikasi';
      notifyListeners();
      return false;
    }

    final index = _books.indexWhere((book) => book.id == id);
    if (index == -1) {
      _errorMessage = 'Buku tidak ditemukan';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final book = _books[index];
      String newStatus = book.status;

      // Auto-update status based on progress
      if (currentPage == 0) {
        newStatus = 'not-started';
      } else if (currentPage >= book.totalPages) {
        newStatus = 'completed';
      } else if (currentPage > 0 && currentPage < book.totalPages) {
        newStatus = 'reading';
      }

      final updatedBook = book.copyWith(
        currentPage: currentPage,
        status: newStatus,
        rating: rating ?? book.rating,
        notes: notes ?? book.notes,
        updatedAt: DateTime.now(),
      );

      // Update in Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('books')
          .doc(id)
          .update(updatedBook.toMap());

      // Update local list
      _books[index] = updatedBook;

      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Gagal mengupdate progress: $e';
      debugPrint('Error updating progress: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mark book as completed
  Future<bool> markAsCompleted(String id) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      _errorMessage = 'User tidak terautentikasi';
      notifyListeners();
      return false;
    }

    final index = _books.indexWhere((book) => book.id == id);
    if (index == -1) {
      _errorMessage = 'Buku tidak ditemukan';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final book = _books[index];
      final updatedBook = book.copyWith(
        currentPage: book.totalPages,
        status: 'completed',
        updatedAt: DateTime.now(),
      );

      // Update in Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('books')
          .doc(id)
          .update(updatedBook.toMap());

      // Update local list
      _books[index] = updatedBook;

      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menandai buku selesai: $e';
      debugPrint('Error marking as completed: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
          book.author.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Get reading statistics for charts
  Map<String, int> getMonthlyReadingStats() {
    final now = DateTime.now();
    final stats = <String, int>{};

    // Initialize last 6 months
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthKey = '${month.month}/${month.year}';
      stats[monthKey] = 0;
    }

    // Count completed books per month
    for (var book in completedBooks) {
      if (book.updatedAt != null) {
        final monthKey = '${book.updatedAt!.month}/${book.updatedAt!.year}';
        if (stats.containsKey(monthKey)) {
          stats[monthKey] = (stats[monthKey] ?? 0) + 1;
        }
      }
    }

    return stats;
  }
}
