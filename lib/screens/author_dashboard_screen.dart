import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'publish_book_screen.dart';
import 'followers_dialog.dart';
import 'analytics_dashboard_screen.dart';

class AuthorDashboardScreen extends StatefulWidget {
  const AuthorDashboardScreen({super.key});

  @override
  State<AuthorDashboardScreen> createState() => _AuthorDashboardScreenState();
}

class _AuthorDashboardScreenState extends State<AuthorDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topSafe = MediaQuery.of(context).padding.top;
    final bottomSafe = MediaQuery.of(context).padding.bottom;
    final currentUserId = firebase_auth.FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      return Scaffold(body: Center(child: Text('Please login first')));
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('published_books')
            .where('authorId', isEqualTo: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          // Handle error
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }

          // Show loading only when no data yet
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Get books data
          final authorBooks = snapshot.data!.docs.map((doc) {
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
            };
          }).toList();

          // Calculate stats
          final publishedCount = authorBooks.length;
          final totalReaders = authorBooks.fold<int>(
            0,
            (total, book) => total + (book['readers'] as int),
          );
          final averageRating = authorBooks.isEmpty
              ? 0.0
              : authorBooks.fold<double>(
                      0,
                      (total, book) => total + (book['rating'] as double),
                    ) /
                    authorBooks.length;

          return Column(
            children: [
              // Header with gradient background
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: topSafe + 20,
                  left: 20,
                  right: 20,
                  bottom: 20,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF9810FA), Color(0xFF8200DB)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Title and icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.dashboard,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Author Dashboard',
                              style: theme.textTheme.displayLarge?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Kelola karya dan lihat statistik',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Stats cards
                    Row(
                      children: [
                        _buildStatCard(
                          context,
                          label: 'Published',
                          value: publishedCount.toString(),
                        ),
                        const SizedBox(width: 12),
                        _buildStatCard(
                          context,
                          label: 'Readers',
                          value: totalReaders.toString(),
                        ),
                        const SizedBox(width: 12),
                        _buildStatCard(
                          context,
                          label: 'Rating',
                          value: averageRating.toStringAsFixed(1),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    bottomSafe + kBottomNavigationBarHeight + 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Aksi section
                      Center(
                        child: Text(
                          'Aksi',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              context,
                              icon: Icons.bar_chart,
                              label: 'Liat Analisis',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AnalyticsDashboardScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildActionButton(
                              context,
                              icon: Icons.people,
                              label: 'Liat Followers',
                              onTap: () {
                                // Show followers dialog
                                showFollowersDialog(context);
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Buku Anda section
                      Center(
                        child: Text(
                          'Buku Anda',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Book list
                      if (authorBooks.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: theme.colorScheme.outline,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.book_outlined,
                                size: 64,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Belum ada buku',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Mulai upload buku pertama Anda',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        )
                      else
                        ...authorBooks.map(
                          (book) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildBookCard(context, book),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to publish book screen
          showPublishBookDialog(context);
        },
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.colorScheme.outline, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFE9D5FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: theme.textTheme.titleMedium)),
          ],
        ),
      ),
    );
  }

  Widget _buildBookCard(BuildContext context, Map<String, dynamic> book) {
    final theme = Theme.of(context);

    // Get stats from book data
    final views = book['views'] as int;
    final readers = book['readers'] as int;
    final rating = book['rating'] as double;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.outline, width: 1),
      ),
      child: Column(
        children: [
          // Book cover
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              book['coverUrl'] ?? '',
              width: 120,
              height: 180,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 120,
                  height: 180,
                  color: theme.colorScheme.outline,
                  child: const Icon(Icons.book, size: 48),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Title and genre
          Text(
            book['title'] ?? 'Untitled',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            book['genre'] ?? 'Tidak ada genre',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Published',
              style: theme.textTheme.labelMedium?.copyWith(
                color: const Color(0xFF008236),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                _buildBookStat(
                  context,
                  label: 'Views',
                  value: views.toString(),
                ),
                const SizedBox(width: 6),
                _buildBookStat(
                  context,
                  label: 'Readers',
                  value: readers.toString(),
                ),
                const SizedBox(width: 6),
                _buildBookStat(
                  context,
                  label: 'Rating',
                  value: rating.toStringAsFixed(1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookStat(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
