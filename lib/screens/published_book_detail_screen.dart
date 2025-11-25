import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../models/book_model.dart';

class PublishedBookDetailScreen extends StatefulWidget {
  final Map<String, dynamic> book;

  const PublishedBookDetailScreen({super.key, required this.book});

  @override
  State<PublishedBookDetailScreen> createState() =>
      _PublishedBookDetailScreenState();
}

class _PublishedBookDetailScreenState extends State<PublishedBookDetailScreen> {
  bool _isAddedToLibrary = false;
  bool _isFollowing = false;
  bool _isLoadingFollow = true;
  bool _isLoadingAdd = true;

  @override
  void initState() {
    super.initState();
    _checkFollowStatus();
    _checkBookInLibrary();
    _incrementViews();
  }

  Future<void> _incrementViews() async {
    try {
      final bookId = widget.book['id'];
      if (bookId == null) return;

      await FirebaseFirestore.instance
          .collection('published_books')
          .doc(bookId)
          .update({'views': FieldValue.increment(1)});
    } catch (e) {
      debugPrint('Error incrementing views: $e');
    }
  }

  Future<void> _checkFollowStatus() async {
    final currentUserId = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      setState(() => _isLoadingFollow = false);
      return;
    }

    var authorId = widget.book['authorId'];

    // Fallback: try to find authorId by author name if not available
    if (authorId == null) {
      final authorName = widget.book['author'];
      if (authorName != null) {
        try {
          final userQuery = await FirebaseFirestore.instance
              .collection('users')
              .where('name', isEqualTo: authorName)
              .where('role', isEqualTo: 'author')
              .limit(1)
              .get();

          if (userQuery.docs.isNotEmpty) {
            authorId = userQuery.docs.first.id;
          }
        } catch (e) {
          // Ignore error
        }
      }
    }

    if (authorId == null || authorId == currentUserId) {
      setState(() => _isLoadingFollow = false);
      return;
    }

    try {
      final followDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(authorId)
          .collection('followers')
          .doc(currentUserId)
          .get();

      setState(() {
        _isFollowing = followDoc.exists;
        _isLoadingFollow = false;
      });
    } catch (e) {
      setState(() => _isLoadingFollow = false);
    }
  }

  Future<void> _checkBookInLibrary() async {
    final currentUserId = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      setState(() => _isLoadingAdd = false);
      return;
    }

    try {
      final bookTitle = widget.book['title'];
      if (bookTitle == null) {
        setState(() => _isLoadingAdd = false);
        return;
      }

      final booksQuery = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('books')
          .where('title', isEqualTo: bookTitle)
          .limit(1)
          .get();

      setState(() {
        _isAddedToLibrary = booksQuery.docs.isNotEmpty;
        _isLoadingAdd = false;
      });
    } catch (e) {
      setState(() => _isLoadingAdd = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topSafe = MediaQuery.of(context).padding.top;
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    // Validate book data
    if (widget.book.isEmpty) {
      return Scaffold(body: Center(child: Text('Book data not found')));
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        children: [
          // Header with gradient and book cover
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFAD46FF),
                  Color(0xFF9810FA),
                  Color(0xFF8200DB),
                ],
              ),
            ),
            child: Column(
              children: [
                // App bar
                Padding(
                  padding: EdgeInsets.only(
                    top: topSafe + 14,
                    left: 20,
                    right: 20,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                // Book cover
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 16,
                    top: 4,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.book['coverUrl'] ?? '',
                      width: 140,
                      height: 210,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 140,
                        height: 210,
                        color: Colors.white.withValues(alpha: 0.2),
                        child: const Icon(
                          Icons.book,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: bottomSafe + 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.book['title'] ?? 'Untitled',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Arimo',
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Author
                  Row(
                    children: [
                      const Icon(Icons.person, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        widget.book['author'] ?? 'Unknown Author',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontFamily: 'Arimo',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Stats row
                  Row(
                    children: [
                      // Rating
                      Row(
                        children: [
                          const Text('⭐', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 4),
                          Text(
                            ((widget.book['rating'] ?? 0.0) as num)
                                .toDouble()
                                .toStringAsFixed(1),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Arimo',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      // Views
                      Row(
                        children: [
                          const Icon(Icons.remove_red_eye, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.book['views'] ?? 0} views',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontFamily: 'Arimo',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      // Readers
                      Row(
                        children: [
                          const Icon(Icons.people, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.book['readers'] ?? 0} readers',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontFamily: 'Arimo',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Genre & Pages
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _buildInfoChip(
                        context,
                        Icons.category,
                        widget.book['genre'] ?? 'Unknown',
                      ),
                      _buildInfoChip(
                        context,
                        Icons.menu_book,
                        '${widget.book['totalPages'] ?? 0} pages',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Action buttons (Follow & Add)
                  Row(
                    children: [
                      // Follow button
                      Expanded(
                        child: _isLoadingFollow
                            ? OutlinedButton(
                                onPressed: null,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : _isFollowing
                            ? ElevatedButton.icon(
                                onPressed: () => _handleFollowAuthor(context),
                                icon: const Icon(Icons.check, size: 18),
                                label: const Text('Following'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10B981),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              )
                            : OutlinedButton.icon(
                                onPressed: () => _handleFollowAuthor(context),
                                icon: const Icon(Icons.person_add, size: 18),
                                label: const Text('Follow'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  side: BorderSide(
                                    color: theme.colorScheme.primary,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),
                      // Add button
                      Expanded(
                        child: _isLoadingAdd
                            ? ElevatedButton(
                                onPressed: null,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : ElevatedButton.icon(
                                onPressed: _isAddedToLibrary
                                    ? null
                                    : () {
                                        _handleAddToLibrary(context);
                                      },
                                icon: Icon(
                                  _isAddedToLibrary
                                      ? Icons.check
                                      : Icons.favorite,
                                  size: 18,
                                ),
                                label: Text(
                                  _isAddedToLibrary ? 'Added' : 'Add',
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  backgroundColor: _isAddedToLibrary
                                      ? Colors.green
                                      : theme.colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: Colors.green,
                                  disabledForegroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Rate button (only if book is in library)
                  if (_isAddedToLibrary)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showRatingDialog(context),
                        icon: const Icon(Icons.star_outline, size: 18),
                        label: const Text('Rate this book'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: theme.colorScheme.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  // Description section
                  Text(
                    'Description',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Arimo',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.book['description'] ?? 'No description available.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                      fontFamily: 'Arimo',
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Content Preview section (if available)
                  if (widget.book.containsKey('contentPreview') &&
                      widget.book['contentPreview'] != null &&
                      widget.book['contentPreview'].toString().isNotEmpty) ...[
                    Text(
                      'Preview',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Arimo',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.book['contentPreview'].toString(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                          fontFamily: 'Arimo',
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  // Published date
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Published: ${_formatDate(widget.book['publishedAt'])}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontFamily: 'Arimo',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(fontFamily: 'Arimo'),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Unknown date';

    try {
      final date = (timestamp as Timestamp).toDate();
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (e) {
      return 'Unknown date';
    }
  }

  Future<void> _handleFollowAuthor(BuildContext context) async {
    final currentUserId = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please login first')));
      return;
    }

    var authorId = widget.book['authorId'];

    // Fallback: try to find authorId by author name if not available
    if (authorId == null) {
      final authorName = widget.book['author'];
      if (authorName != null) {
        try {
          final userQuery = await FirebaseFirestore.instance
              .collection('users')
              .where('name', isEqualTo: authorName)
              .where('role', isEqualTo: 'author')
              .limit(1)
              .get();

          if (userQuery.docs.isNotEmpty) {
            authorId = userQuery.docs.first.id;
          }
        } catch (e) {
          // Ignore error and show message below
        }
      }

      if (authorId == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Author information not found')),
          );
        }
        return;
      }
    }

    // Can't follow yourself
    if (authorId == currentUserId) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You cannot follow yourself')),
        );
      }
      return;
    }

    try {
      final followerRef = FirebaseFirestore.instance
          .collection('users')
          .doc(authorId)
          .collection('followers')
          .doc(currentUserId);

      if (_isFollowing) {
        // Unfollow
        await followerRef.delete();
        setState(() => _isFollowing = false);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Unfollowed ${widget.book['author']}')),
          );
        }
      } else {
        // Follow
        // Get current user data
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .get();

        final userData = userDoc.data();

        await followerRef.set({
          'userId': currentUserId,
          'name': userData?['name'] ?? 'Unknown User',
          'email': userData?['email'] ?? '',
          'role': userData?['role'] ?? 'reader',
          'followedAt': FieldValue.serverTimestamp(),
        });

        setState(() => _isFollowing = true);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Following ${widget.book['author']}')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  void _handleAddToLibrary(BuildContext context) async {
    try {
      final bookProvider = Provider.of<BookProvider>(context, listen: false);

      // Convert published book to Book model for user's library
      final newBook = Book(
        id: '', // Will be generated by BookProvider
        title: widget.book['title'] ?? 'Untitled',
        author: widget.book['author'] ?? 'Unknown Author',
        genre: widget.book['genre'] ?? 'Unknown',
        totalPages: widget.book['totalPages'] ?? 0,
        currentPage: 0,
        rating: ((widget.book['rating'] ?? 0.0) as num)
            .toDouble()
            .round(), // Convert to int safely
        imageUrl: widget.book['coverUrl'] ?? '',
        notes: widget.book['description'] ?? '', // Store description as notes
      );

      await bookProvider.addBook(newBook);

      // Increment readers count in published_books
      final bookId = widget.book['id'];
      if (bookId != null) {
        await FirebaseFirestore.instance
            .collection('published_books')
            .doc(bookId)
            .update({'readers': FieldValue.increment(1)});
      }

      if (context.mounted) {
        setState(() {
          _isAddedToLibrary = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${widget.book['title']} ditambahkan ke daftar buku Anda',
            ),
            duration: const Duration(seconds: 2),
            action: SnackBarAction(label: 'OK', onPressed: () {}),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menambahkan buku: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showRatingDialog(BuildContext context) async {
    int selectedRating = 0;

    // Check if user has already rated this book
    final currentUserId = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
    final bookId = widget.book['id'];

    if (currentUserId != null && bookId != null) {
      try {
        final userRatingDoc = await FirebaseFirestore.instance
            .collection('published_books')
            .doc(bookId)
            .collection('user_ratings')
            .doc(currentUserId)
            .get();

        if (userRatingDoc.exists) {
          selectedRating = (userRatingDoc.data()?['rating'] ?? 0) as int;
        }
      } catch (e) {
        debugPrint('Error checking user rating: $e');
      }
    }

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Rate this book',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'How would you rate this book?',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            selectedRating = index + 1;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Icon(
                            index < selectedRating
                                ? Icons.star
                                : Icons.star_border,
                            size: 36,
                            color: index < selectedRating
                                ? Colors.amber
                                : Colors.grey,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  if (selectedRating > 0)
                    Text(
                      '$selectedRating star${selectedRating > 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: selectedRating > 0
                      ? () async {
                          Navigator.of(dialogContext).pop();
                          await _submitRating(context, selectedRating);
                        }
                      : null,
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _submitRating(BuildContext context, int rating) async {
    try {
      final currentUserId =
          firebase_auth.FirebaseAuth.instance.currentUser?.uid;
      final bookId = widget.book['id'];

      if (currentUserId == null || bookId == null) return;

      final bookRef = FirebaseFirestore.instance
          .collection('published_books')
          .doc(bookId);

      final userRatingRef = bookRef
          .collection('user_ratings')
          .doc(currentUserId);

      // Check if user has already rated
      final userRatingDoc = await userRatingRef.get();
      final hadRatedBefore = userRatingDoc.exists;
      final previousRating = hadRatedBefore
          ? (userRatingDoc.data()?['rating'] ?? 0) as int
          : 0;

      // Get current book data
      final bookDoc = await bookRef.get();
      if (!bookDoc.exists) return;

      final currentAvgRating = (bookDoc.data()?['rating'] ?? 0.0) as num;
      final currentCount = (bookDoc.data()?['ratingsCount'] ?? 0) as int;

      // Calculate new average rating
      double newAverage;
      int newCount;

      if (hadRatedBefore) {
        // Update existing rating: remove old, add new
        final totalRating =
            currentAvgRating * currentCount - previousRating + rating;
        newCount = currentCount; // Count stays the same
        newAverage = currentCount > 0
            ? totalRating / currentCount
            : rating.toDouble();
      } else {
        // New rating: add to total
        final totalRating = currentAvgRating * currentCount + rating;
        newCount = currentCount + 1;
        newAverage = totalRating / newCount;
      }

      // Save user's rating
      await userRatingRef.set({
        'rating': rating,
        'userId': currentUserId,
        'ratedAt': FieldValue.serverTimestamp(),
      });

      // Update book with new average rating
      await bookRef.update({'rating': newAverage, 'ratingsCount': newCount});

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              hadRatedBefore
                  ? 'Rating updated! You gave $rating stars.'
                  : 'Thank you for rating! You gave $rating stars.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit rating: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
