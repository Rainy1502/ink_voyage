import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ink_voyage/providers/book_provider.dart';
import 'package:ink_voyage/widgets/vertical_book_card.dart';

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
              child: Consumer<BookProvider>(
                builder: (context, provider, _) {
                  // NOTE: Discover should show works uploaded by authors (feature coming later).
                  // For now keep Discover empty so it won't surface books from the main "Daftar Buku" list.
                  final allBooks = <dynamic>[];

                  // Build genre list
                  final genres = <String>{'Semua'};
                  for (final b in allBooks) {
                    if (b.genre != null && b.genre!.trim().isNotEmpty) {
                      genres.add(b.genre!);
                    }
                  }
                  final genreList = genres.toList();

                  // Filter by search & genre
                  final query = _searchController.text.trim().toLowerCase();
                  final filtered = allBooks.where((b) {
                    final matchesGenre =
                        _selectedGenre == 'Semua' ||
                        (b.genre ?? '') == _selectedGenre;
                    final haystack = '${b.title} ${b.author} ${b.genre ?? ''}';
                    final matchesQuery =
                        query.isEmpty || haystack.toLowerCase().contains(query);
                    return matchesGenre && matchesQuery;
                  }).toList();

                  // Sorting
                  if (_selectedSort == 'Terbaru') {
                    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                  } else if (_selectedSort == 'Rating Tertinggi') {
                    filtered.sort(
                      (a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0),
                    );
                  } else if (_selectedSort == 'Paling Populer') {
                    // popular: for now sort by rating as a simple proxy
                    filtered.sort(
                      (a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0),
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
                                        child: VerticalBookCard(
                                          book: b,
                                          onFollow: () {},
                                          onAdd: () {},
                                          onTap: () => Navigator.pushNamed(
                                            context,
                                            '/book-detail',
                                            arguments: b.id,
                                          ),
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
}
