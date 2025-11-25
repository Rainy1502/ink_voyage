import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'published_book_detail_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedGenre = 'Semua';
  String _selectedSort = 'Terbaru';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topSafe = MediaQuery.of(context).padding.top;
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            height: 200,
            padding: EdgeInsets.only(
              top: topSafe + 14,
              left: 20,
              right: 20,
              bottom: 12,
            ),
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Discover Book', style: theme.appBarTheme.titleTextStyle),
                const SizedBox(height: 6),
                Text(
                  'Jelajahi koleksi & temukan bacaan baru',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 10),
                // Search field
                SizedBox(
                  height: 48,
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.white70,
                      ),
                      hintText: 'Cari judul, penulis, atau genre',
                      hintStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: const Color(0xFF9810FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('published_books')
                    .snapshots(),
                builder: (context, snapshot) {
                  // Show loading or error
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final allBooks = snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return {
                      'id': doc.id,
                      'title': data['title'] ?? '',
                      'author': data['author'] ?? '',
                      'authorId': data['authorId'],
                      'genre': data['genre'] ?? '',
                      'coverUrl': data['coverUrl'] ?? '',
                      'description': data['description'] ?? '',
                      'contentPreview': data['contentPreview'],
                      'totalPages': data['totalPages'] ?? 0,
                      'rating': ((data['rating'] ?? 0.0) as num).toDouble(),
                      'ratingsCount': data['ratingsCount'] ?? 0,
                      'views': data['views'] ?? 0,
                      'readers': data['readers'] ?? 0,
                      'publishedAt': data['publishedAt'] ?? Timestamp.now(),
                    };
                  }).toList();

                  // Build genre list
                  final genres = <String>{'Semua'};
                  for (final b in allBooks) {
                    final genre = b['genre'] as String?;
                    if (genre != null && genre.trim().isNotEmpty) {
                      genres.add(genre);
                    }
                  }
                  final genreList = genres.toList();

                  // Filter by search & genre
                  final query = _searchController.text.trim().toLowerCase();
                  final filtered = allBooks.where((b) {
                    final matchesGenre =
                        _selectedGenre == 'Semua' ||
                        (b['genre'] ?? '') == _selectedGenre;
                    final haystack =
                        '${b['title']} ${b['author']} ${b['genre'] ?? ''}';
                    final matchesQuery =
                        query.isEmpty || haystack.toLowerCase().contains(query);
                    return matchesGenre && matchesQuery;
                  }).toList();

                  // Sorting
                  if (_selectedSort == 'Terbaru') {
                    filtered.sort((a, b) {
                      final aTime = a['publishedAt'] as Timestamp;
                      final bTime = b['publishedAt'] as Timestamp;
                      return bTime.compareTo(aTime);
                    });
                  } else if (_selectedSort == 'Rating Tertinggi') {
                    filtered.sort(
                      (a, b) => (b['rating'] as double).compareTo(
                        a['rating'] as double,
                      ),
                    );
                  } else if (_selectedSort == 'Paling Populer') {
                    filtered.sort(
                      (a, b) =>
                          (b['views'] as int).compareTo(a['views'] as int),
                    );
                  }

                  final bottomPadding =
                      bottomSafe + kBottomNavigationBarHeight + 16;

                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dropdown row: Genre (left) + Sort (right)
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedGenre,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                ),
                                items: genreList
                                    .map(
                                      (g) => DropdownMenuItem(
                                        value: g,
                                        child: Text(g),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) => setState(() {
                                  _selectedGenre = v ?? 'Semua';
                                }),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 1,
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedSort,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Terbaru',
                                    child: Text('Terbaru'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Rating Tertinggi',
                                    child: Text('Rating Tertinggi'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Paling Populer',
                                    child: Text('Paling Populer'),
                                  ),
                                ],
                                onChanged: (v) => setState(() {
                                  _selectedSort = v ?? 'Terbaru';
                                }),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Single filtered list controlled only by dropdowns (genre + sort)
                        // Build the body widget (either empty-state or the list) to avoid flow-control lint
                        Builder(
                          builder: (context) {
                            final Widget bodyContent;
                            if (filtered.isEmpty) {
                              bodyContent = Padding(
                                padding: const EdgeInsets.only(
                                  top: 36,
                                  bottom: 80,
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.menu_book_outlined,
                                        size: 72,
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.22),
                                      ),
                                      const SizedBox(height: 18),
                                      Text(
                                        'Tidak ada buku ditemukan',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Belum ada buku yang dipublikasikan',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: theme.colorScheme.onSurface
                                                  .withValues(alpha: 0.6),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              bodyContent = Column(
                                children: filtered
                                    .map(
                                      (b) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 12.0,
                                        ),
                                        child: _buildPublishedBookCard(
                                          context,
                                          b,
                                        ),
                                      ),
                                    )
                                    .toList(),
                              );
                            }

                            return bodyContent;
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPublishedBookCard(
    BuildContext context,
    Map<String, dynamic> book,
  ) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PublishedBookDetailScreen(book: book),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                book['coverUrl'] as String,
                width: 80,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 120,
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    child: Icon(
                      Icons.book,
                      size: 40,
                      color: theme.colorScheme.primary,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),

            // Book info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    book['title'] as String,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Arimo',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Author
                  Text(
                    'by ${book['author']}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      fontFamily: 'Arimo',
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Genre badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9D5FF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      book['genre'] as String,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF7C3AED),
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Arimo',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Description preview
                  Text(
                    book['description'] as String,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      height: 1.4,
                      fontFamily: 'Arimo',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Stats row
                  Row(
                    children: [
                      // Views
                      Icon(
                        Icons.remove_red_eye,
                        size: 14,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${book['views']}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'Arimo',
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Pages
                      Icon(
                        Icons.description,
                        size: 14,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${book['totalPages']}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'Arimo',
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Rating
                      Icon(Icons.star, size: 14, color: Colors.amber[700]),
                      const SizedBox(width: 4),
                      Text(
                        (book['rating'] as double).toStringAsFixed(1),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'Arimo',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
