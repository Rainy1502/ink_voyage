import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book_model.dart';
import '../providers/book_provider.dart';
import '../widgets/large_book_card.dart';
import '../widgets/book_card.dart';
import 'add_book_url_screen.dart';
import 'edit_book_screen.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Semua';
  String _selectedGenre = 'Semua Genre';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookProvider>(context, listen: false).loadBooks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Book> _getFilteredBooks(BookProvider provider) {
    // Start with all books, then filter by status, then apply search on the subset
    List<Book> books;
    switch (_selectedFilter) {
      case 'Sedang Dibaca':
        books = provider.readingBooks;
        break;
      case 'Selesai':
        books = provider.completedBooks;
        break;
      case 'Belum Mulai':
        books = provider.notStartedBooks;
        break;
      case 'Semua':
      default:
        books = provider.books;
    }

    // Apply genre filter if selected
    if (_selectedGenre != 'Semua Genre') {
      final genreLower = _selectedGenre.toLowerCase();
      books = books
          .where((b) => (b.genre ?? '').toLowerCase() == genreLower)
          .toList();
    }

    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      books = books
          .where(
            (b) =>
                b.title.toLowerCase().contains(query) ||
                b.author.toLowerCase().contains(query),
          )
          .toList();
    }
    return books;
  }

  void _showDeleteConfirmation(BuildContext context, Book book) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Hapus Buku',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Yakin ingin menghapus "${book.title}"?',
            style: theme.textTheme.bodyLarge,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
            ),
            TextButton(
              onPressed: () {
                Provider.of<BookProvider>(
                  context,
                  listen: false,
                ).deleteBook(book.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Buku berhasil dihapus')),
                );
              },
              child: Text(
                'Hapus',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Daftar Buku'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Image.asset(
              'assets/images/Logo.png',
              height: 300,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFAD46FF),
                  Color(0xFF9810FA),
                  Color(0xFF8200DB),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
          // Content area
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: kToolbarHeight - 56),
                // Search below outside title (AppBar)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 2),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Cari judul atau penulis',
                      hintStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Colors.white24,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Colors.white24,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Colors.white24,
                          width: 1,
                        ),
                      ),
                      filled: true,
                      fillColor: Color(0xFF9A22EF),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                // Status & Genre dropdowns below search and outside white container
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
                  child: Consumer<BookProvider>(
                    builder: (context, provider, _) {
                      final genres =
                          provider.books
                              .map((b) => (b.genre ?? '').trim())
                              .where((g) => g.isNotEmpty)
                              .toSet()
                              .toList()
                            ..sort(
                              (a, b) =>
                                  a.toLowerCase().compareTo(b.toLowerCase()),
                            );

                      // Normalize selected values to avoid Dropdown assertion
                      final allowedStatusValues = const [
                        'Semua',
                        'Sedang Dibaca',
                        'Selesai',
                        'Belum Mulai',
                      ];
                      final normalizedStatus =
                          allowedStatusValues.contains(_selectedFilter)
                          ? _selectedFilter
                          : 'Semua';
                      final allGenres = ['Semua Genre', ...genres];
                      final normalizedGenre =
                          allGenres.any(
                            (g) =>
                                g.toLowerCase() == _selectedGenre.toLowerCase(),
                          )
                          ? _selectedGenre
                          : 'Semua Genre';

                      return Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: normalizedStatus,
                              isExpanded: true,
                              selectedItemBuilder: (context) {
                                // Display labels aligned with the corresponding items order
                                const labels = [
                                  'Semua Status',
                                  'Dibaca',
                                  'Selesai',
                                  'Belum Mulai',
                                ];
                                return labels
                                    .map(
                                      (t) => Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          t,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: false,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList();
                              },
                              decoration: InputDecoration(
                                isDense: true,
                                filled: true,
                                fillColor: const Color(0xFF9A22EF),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.white24,
                                    width: 1,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.white24,
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.white24,
                                    width: 1,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 10,
                                ),
                              ),
                              // Use black for dropdown menu items text
                              style: const TextStyle(color: Colors.black),
                              dropdownColor: Colors.white,
                              icon: const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.white,
                              ),
                              iconSize: 20,
                              items: [
                                DropdownMenuItem(
                                  value: 'Semua',
                                  child: Text(
                                    'Semua',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'Sedang Dibaca',
                                  child: Text(
                                    'Dibaca',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'Selesai',
                                  child: Text(
                                    'Selesai',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'Belum Mulai',
                                  child: Text(
                                    'Belum Mulai',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ),
                              ],
                              onChanged: (val) {
                                if (val == null) return;
                                setState(() => _selectedFilter = val);
                              },
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: normalizedGenre,
                              isExpanded: true,
                              selectedItemBuilder: (context) {
                                final labels = ['Semua Genre', ...genres];
                                return labels
                                    .map(
                                      (t) => Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          t,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: false,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList();
                              },
                              decoration: InputDecoration(
                                isDense: true,
                                filled: true,
                                fillColor: const Color(0xFF9A22EF),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.white24,
                                    width: 1,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.white24,
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.white24,
                                    width: 1,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 10,
                                ),
                              ),
                              style: const TextStyle(color: Colors.black),
                              dropdownColor: Colors.white,
                              icon: const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.white,
                              ),
                              iconSize: 20,
                              items: [
                                DropdownMenuItem(
                                  value: 'Semua Genre',
                                  child: Text(
                                    'Semua',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ),
                                ...genres.map(
                                  (g) => DropdownMenuItem(
                                    value: g,
                                    child: Text(
                                      g,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (val) {
                                if (val == null) return;
                                setState(() => _selectedGenre = val);
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 15,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary stats cards
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                          child: Consumer<BookProvider>(
                            builder: (context, provider, _) {
                              return Row(
                                children: [
                                  _StatCard(
                                    label: 'Ditambahkan',
                                    value: provider.totalBooks,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  _StatCard(
                                    label: 'Dibaca',
                                    value: provider.readingCount,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(width: 8),
                                  _StatCard(
                                    label: 'Selesai',
                                    value: provider.completedCount,
                                    color: Colors.green,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        // Books List
                        Expanded(
                          child: Consumer<BookProvider>(
                            builder: (context, provider, child) {
                              final books = _getFilteredBooks(provider);

                              if (books.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.library_books_outlined,
                                        size: 80,
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.3),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Belum ada buku',
                                        style: theme.textTheme.titleLarge
                                            ?.copyWith(
                                              color: theme.colorScheme.onSurface
                                                  .withValues(alpha: 0.6),
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Ketuk + untuk menambahkan buku pertama',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: theme.colorScheme.onSurface
                                                  .withValues(alpha: 0.4),
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                itemCount: books.length,
                                itemBuilder: (context, index) {
                                  final book = books[index];
                                  return Align(
                                    alignment: Alignment.topCenter,
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 360,
                                      ),
                                      child: LargeBookCard(
                                        book: book,
                                        onTap: () {
                                          // Show edit dialog
                                          showEditBookDialog(context, book.id);
                                        },
                                        onLongPress: () =>
                                            _showDeleteConfirmation(
                                              context,
                                              book,
                                            ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddBookDialog(context),
        backgroundColor: theme.colorScheme.primary,
        elevation: 6,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // chips removed in favor of dropdowns
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  value.toString(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BookSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final provider = Provider.of<BookProvider>(context);
    final books = provider.searchBooks(query);

    if (books.isEmpty) {
      return Center(
        child: Text(
          'No books found',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return BookCard(
          book: book,
          onTap: () {
            close(context, book.id);
            Navigator.pushNamed(context, '/book-detail', arguments: book.id);
          },
        );
      },
    );
  }
}
