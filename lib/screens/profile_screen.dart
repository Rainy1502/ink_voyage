import 'package:flutter/material.dart';
// 'flutter/services.dart' not needed; material.dart already exports platform services
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import '../providers/book_provider.dart';
import 'become_author_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Helper method to safely check application status
  bool _hasPendingApplication(dynamic user) {
    try {
      if (user == null) return false;
      final status = user.authorApplicationStatus;
      return status != null && status == 'pending';
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> _fetchAuthorStats(String userId) async {
    try {
      // Fetch published books (only status = 'published')
      final booksSnapshot = await FirebaseFirestore.instance
          .collection('published_books')
          .where('authorId', isEqualTo: userId)
          .where('status', isEqualTo: 'published')
          .get();

      int totalViews = 0;
      int publishedBooks = booksSnapshot.docs.length;
      double totalRating = 0;
      int ratingCount = 0;

      for (var doc in booksSnapshot.docs) {
        final data = doc.data();
        totalViews += (data['views'] ?? 0) as int;

        final rating = ((data['rating'] ?? 0.0) as num).toDouble();
        final ratings = (data['ratingsCount'] ?? 0) as int;
        totalRating += rating * ratings;
        ratingCount += ratings;
      }

      double avgRating = ratingCount > 0 ? totalRating / ratingCount : 0.0;

      // Fetch followers count
      final followersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('followers')
          .get();

      return {
        'published': publishedBooks,
        'views': totalViews,
        'avgRating': avgRating.toStringAsFixed(1),
        'followers': followersSnapshot.docs.length,
      };
    } catch (e) {
      return {'published': 0, 'views': 0, 'avgRating': '0.0', 'followers': 0};
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: const Text(
            'Keluar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A0A0A),
            ),
          ),
          content: const Text('Apakah Anda yakin ingin keluar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final authProvider = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                );
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/login', (route) => false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE7000B),
                foregroundColor: Colors.white,
              ),
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAuthorProfileCard(BuildContext context, user) {
    final authorProfile = user.authorProfile as Map<String, dynamic>?;
    final bio = (authorProfile != null && authorProfile['bio'] != null)
        ? authorProfile['bio'].toString()
        : 'Belum ada bio.';

    String authorSince = '';
    try {
      if (authorProfile != null && authorProfile['appliedAt'] != null) {
        final dt = DateTime.parse(authorProfile['appliedAt'].toString());
        final months = [
          'Januari',
          'Februari',
          'Maret',
          'April',
          'Mei',
          'Juni',
          'Juli',
          'Agustus',
          'September',
          'Oktober',
          'November',
          'Desember',
        ];
        authorSince = '${dt.day} ${months[dt.month - 1]} ${dt.year}';
      }
    } catch (_) {
      authorSince = '';
    }

    // Fetch stats from Firestore using FutureBuilder for one-time load
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchAuthorStats(user.id),
      builder: (context, snapshot) {
        // Default values
        String published = '0';
        String views = '0';
        String avgRating = '0.0';
        String followers = '0';

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.1),
                width: 1.162,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8200DB)),
              ),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          final data = snapshot.data!;
          published = data['published'].toString();
          views = data['views'].toString();
          avgRating = data['avgRating'].toString();
          followers = data['followers'].toString();
        }

        return _buildAuthorProfileCardContent(
          context,
          bio,
          authorSince,
          followers,
          published,
          views,
          avgRating,
        );
      },
    );
  }

  Widget _buildAuthorProfileCardContent(
    BuildContext context,
    String bio,
    String authorSince,
    String followers,
    String published,
    String views,
    String avgRating,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(1.333),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.06),
          width: 1.162,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        // adjust top/bottom padding
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8200DB),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.edit, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Author Profile',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Statistik karya Anda',
                      style: TextStyle(fontSize: 14, color: Color(0xFF717182)),
                    ),
                  ],
                ),
              ],
            ),

            // Small gap between header and bio
            const SizedBox(height: 8),

            // Bio box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F3FB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.menu_book, size: 18, color: Color(0xFF8200DB)),
                      SizedBox(width: 8),
                      Text(
                        'Bio',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(bio),
                ],
              ),
            ),

            // small gap between bio and stats
            const SizedBox(height: 6),

            // Two rows with two stat cards each — deterministic layout
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _smallStatCard(
                        icon: Icons.group,
                        value: followers,
                        label: 'Followers',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _smallStatCard(
                        icon: Icons.menu_book,
                        value: published,
                        label: 'Published',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _smallStatCard(
                        icon: Icons.remove_red_eye,
                        value: views,
                        label: 'Total Views',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _smallStatCard(
                        icon: Icons.star_border,
                        value: avgRating,
                        label: 'Avg Rating',
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (authorSince.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                    color: Color(0xFF717182),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Author sejak $authorSince',
                    style: const TextStyle(color: Color(0xFF717182)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _smallStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.06),
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF8200DB)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 20, color: Color(0xFF8200DB)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6A7282)),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationPendingCard(BuildContext context, user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF), // blue-50
        border: Border.all(
          color: const Color(0xFFBEDBFF), // blue-200
          width: 1.333,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 16, color: Color(0xFF1447E6)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Aplikasi Author Sedang Direview',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C398E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Moderator sedang meninjau aplikasi Anda. Anda akan diberi notifikasi setelah direview.',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF1447E6),
                    height: 1.333,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard(BuildContext context, user) {
    // Check if user has pending application - safely access the property
    final hasPendingApplication = _hasPendingApplication(user);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(1.333),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.1),
          width: 1.162,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDCCFF),
                    border: Border.all(
                      color: const Color(0xFFDAB2FF),
                      width: 1.162,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Builder(
                      builder: (context) {
                        final role = (user.role ?? 'reader')
                            .toString()
                            .toLowerCase();
                        if (role == 'author') {
                          return Image.asset(
                            'assets/icons/pen.png',
                            width: 20,
                            height: 20,
                            fit: BoxFit.contain,
                            errorBuilder: (ctx, err, st) => const Icon(
                              Icons.edit,
                              size: 20,
                              color: Color(0xFF8200DB),
                            ),
                          );
                        }

                        return const Icon(
                          Icons.person_outline,
                          size: 20,
                          color: Color(0xFF8200DB),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Role',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Color(0xFF6A7282),
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Dynamic badge based on user's role
                      Builder(
                        builder: (context) {
                          final role = user.role.toString().toLowerCase();

                          if (role == 'moderator') {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: const Color(0xFFDC2626),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Text(
                                'Moderator',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFDC2626),
                                ),
                              ),
                            );
                          }

                          if (role == 'author') {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: const Color(0xFF8200DB),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Text(
                                'Author',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                  color: Color(0xFF8200DB),
                                ),
                              ),
                            );
                          }

                          // default: reader
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: const Color(0xFF2D9CFF),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Reader',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12), // Badge/Button on the right side
                Builder(
                  builder: (context) {
                    final role = user.role.toString().toLowerCase();

                    // Show "Application Pending" badge if user has pending application
                    if (hasPendingApplication) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          border: Border.all(
                            color: const Color(0xFFFCD34D),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.schedule,
                              size: 12,
                              color: Color(0xFFD97706),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Pending',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFD97706),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Moderator: no button (to prevent text overflow)
                    if (role == 'moderator') {
                      return const SizedBox.shrink();
                    }

                    // Author: show verified badge
                    if (role == 'author') {
                      return OutlinedButton.icon(
                        onPressed: null,
                        icon: const Icon(
                          Icons.verified,
                          size: 18,
                          color: Color(0xFF8200DB),
                        ),
                        label: const Text(
                          'Author',
                          style: TextStyle(color: Color(0xFF8200DB)),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    }

                    // Reader: show become author button
                    return ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const BecomeAuthorScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Jadi Author'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8200DB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            // Show pending info card if application is pending
            if (hasPendingApplication) ...[
              const SizedBox(height: 12),
              _buildApplicationPendingCard(context, user),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use AppBar + extendBodyBehindAppBar so header gradient sits behind status bar
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFF3F3F5),
      body: SafeArea(
        top: false,
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            final user = authProvider.currentUser;

            if (user == null) {
              return const Center(child: Text('No user data'));
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  // Header with gradient (without bottom padding for overlap)
                  _buildHeader(context, user),

                  // Content with negative margin to overlap header
                  Transform.translate(
                    offset: const Offset(0, -48),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 26),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 8),

                          // Role Card (overlapping header)
                          _buildRoleCard(context, user),

                          // Author profile card (only when user is author)
                          if (user.role.toString().toLowerCase() ==
                              'author') ...[
                            const SizedBox(height: 16),
                            _buildAuthorProfileCard(context, user),
                          ],

                          const SizedBox(height: 16),

                          // Statistics Grid
                          Consumer<BookProvider>(
                            builder: (context, bookProvider, child) {
                              return _buildStatisticsGrid(
                                context,
                                bookProvider,
                              );
                            },
                          ),

                          const SizedBox(height: 16),

                          // Informasi Akun Card
                          _buildAccountInfoCard(context, user),

                          const SizedBox(height: 16),

                          // Achievement Card - hanya muncul jika ada buku selesai
                          Consumer<BookProvider>(
                            builder: (context, bookProvider, child) {
                              // Hanya tampilkan jika ada buku yang selesai
                              if (bookProvider.completedCount > 0) {
                                return Column(
                                  children: [
                                    _buildAchievementCard(
                                      context,
                                      bookProvider,
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                );
                              }
                              // Return empty widget jika belum ada buku selesai
                              return const SizedBox.shrink();
                            },
                          ),

                          // Logout Button
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => _showLogoutDialog(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                backgroundColor: Colors.white,
                                side: const BorderSide(
                                  color: Color(0xFFE7000B),
                                  width: 1.333,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.logout,
                                    size: 16,
                                    color: Color(0xFFE7000B),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Keluar',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                      color: Color(0xFFE7000B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 32,
                          ), // Bottom navigation padding
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, user) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFAD46FF), Color(0xFF9810FA), Color(0xFF8200DB)],
        ),
        border: Border(
          bottom: BorderSide(color: Color(0xFFDAB2FF), width: 1.162),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 50, 24, 72),
      child: Column(
        children: [
          // Title
          Container(
            height: 32,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Text(
              'Profil Saya',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.normal,
                color: Colors.white,
                height: 1.33,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 32),

          // Profile Info
          Column(
            children: [
              // Avatar Circle
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF8200DB),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        user.initial,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.normal,
                          color: Colors.white,
                          height: 1.33,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Name
              Container(
                height: 32,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                    height: 1.33,
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // Email
              Container(
                height: 24,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  user.email,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Color(0xFFEDCCFF),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsGrid(BuildContext context, BookProvider bookProvider) {
    return Column(
      children: [
        // Row 1
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.menu_book,
                value: bookProvider.totalBooks.toString(),
                label: 'Total Buku',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                icon: Icons.trending_up,
                value: bookProvider.readingCount.toString(),
                label: 'Sedang Dibaca',
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Row 2
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.check_circle_outline,
                value: bookProvider.completedCount.toString(),
                label: 'Selesai',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                icon: Icons.menu_book,
                value: bookProvider.totalPagesRead.toString(),
                label: 'Halaman Dibaca',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    const cardColor = Color(0xFF8200DB); // Purple untuk semua stat cards

    return Container(
      height: 134.667,
      padding: const EdgeInsets.all(1.333),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.1),
          width: 1.162,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: cardColor),

            const SizedBox(height: 8),

            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.normal,
                color: cardColor,
                height: 1.33,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Color(0xFF6A7282),
                height: 1.43,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountInfoCard(BuildContext context, user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(1.333),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.1),
          width: 1.162,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Title
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Text(
              'Informasi Akun',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Color(0xFF0A0A0A),
                height: 1.0,
              ),
            ),
          ),

          // Card Content
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Column(
              children: [
                _buildInfoRow(
                  icon: Icons.person_outline,
                  label: 'Nama Lengkap',
                  value: user.name,
                ),

                const SizedBox(height: 16),

                _buildInfoRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: user.email,
                ),

                const SizedBox(height: 16),

                _buildInfoRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Bergabung Sejak',
                  value: user.createdAt,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 38.667,
          height: 38.667,
          decoration: BoxDecoration(
            color: const Color(0xFFEDCCFF),
            border: Border.all(color: const Color(0xFFDAB2FF), width: 1.162),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Icon(icon, size: 20, color: const Color(0xFF8200DB)),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Color(0xFF6A7282),
                  height: 1.43,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Color(0xFF101828),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementCard(
    BuildContext context,
    BookProvider bookProvider,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(1.333),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.1),
          width: 1.333,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pencapaian Membaca',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Color(0xFF0A0A0A),
                    height: 1.0,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Progress membaca Anda sejauh ini',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Color(0xFF717182),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // Achievement Content
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 17.333,
                vertical: 1.333,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFEDCCFF),
                border: Border.all(
                  color: const Color(0xFFE9D4FF),
                  width: 1.333,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: const Center(
                      child: Text('🏅', style: TextStyle(fontSize: 24)),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pembaca Aktif',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: Color(0xFF101828),
                            height: 1.5,
                          ),
                        ),
                        Text(
                          '${bookProvider.completedCount} buku selesai',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: Color(0xFF9810FA),
                            height: 1.43,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Trophy
                  const Text('🏆', style: TextStyle(fontSize: 24)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
