import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/author_application_service.dart';
import 'package:intl/intl.dart';

class ModeratorDashboardScreen extends StatefulWidget {
  const ModeratorDashboardScreen({super.key});

  @override
  State<ModeratorDashboardScreen> createState() =>
      _ModeratorDashboardScreenState();
}

class _ModeratorDashboardScreenState extends State<ModeratorDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AuthorApplicationService _applicationService =
      AuthorApplicationService();

  // Helper to safely parse date from Firestore (can be Timestamp or String)
  DateTime _parseDate(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();

    if (dateValue is Timestamp) {
      return dateValue.toDate();
    }

    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        return DateTime.now();
      }
    }

    return DateTime.now();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _testFirestoreConnection();
  }

  Future<void> _testFirestoreConnection() async {
    try {
      debugPrint('🔥 Testing Firestore connection...');
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();
      debugPrint('🔥 Users collection: ${usersSnapshot.docs.length} documents');

      for (var doc in usersSnapshot.docs) {
        final role = (doc.data() as Map<String, dynamic>?)?['role'];
        debugPrint('🔥 User: ${doc.id} - role: $role');
      }

      // Test other collections
      try {
        final appsSnapshot = await FirebaseFirestore.instance
            .collection('author_applications')
            .get();
        debugPrint(
          '🔥 Applications collection: ${appsSnapshot.docs.length} documents',
        );
      } catch (e) {
        debugPrint('🔥 Applications collection error: $e');
      }

      try {
        final booksSnapshot = await FirebaseFirestore.instance
            .collection('published_books')
            .get();
        debugPrint(
          '🔥 Books collection: ${booksSnapshot.docs.length} documents',
        );
      } catch (e) {
        debugPrint('🔥 Books collection error: $e');
      }
    } catch (e) {
      debugPrint('🔥 Firestore test ERROR: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Stream<Map<String, int>> _statsStream() {
    // Combine multiple streams to get real-time stats
    return FirebaseFirestore.instance.collection('users').snapshots().asyncMap((
      usersSnapshot,
    ) async {
      try {
        debugPrint('📊 Users snapshot: ${usersSnapshot.docs.length} docs');

        // Count users by role (safely check if role field exists)
        int totalUsers = usersSnapshot.docs.length;
        int totalAuthors = usersSnapshot.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>?;
          return data != null &&
              data.containsKey('role') &&
              data['role'] == 'author';
        }).length;

        debugPrint('📊 Users: $totalUsers, Authors: $totalAuthors');

        // Count pending applications
        int pendingCount = 0;
        try {
          final appsSnapshot = await FirebaseFirestore.instance
              .collection('author_applications')
              .where('status', isEqualTo: 'pending')
              .get();
          pendingCount = appsSnapshot.docs.length;
          debugPrint('📊 Pending Applications: $pendingCount');
        } catch (e) {
          debugPrint('📊 ❌ Error fetching applications: $e');
        }

        // Count books
        int totalBooks = 0;
        int publishedBooks = 0;
        try {
          final booksSnapshot = await FirebaseFirestore.instance
              .collection('published_books')
              .get();
          totalBooks = booksSnapshot.docs.length;
          publishedBooks = booksSnapshot.docs
              .where((doc) => doc['status'] == 'published')
              .length;
          debugPrint('📊 Total Books: $totalBooks, Published: $publishedBooks');
        } catch (e) {
          debugPrint('📊 ❌ Error fetching books: $e');
        }

        final stats = {
          'users': totalUsers,
          'authors': totalAuthors,
          'pending': pendingCount,
          'books': totalBooks,
          'published': publishedBooks,
        };

        debugPrint('📊 ✅ Final Stats: $stats');
        return stats;
      } catch (e) {
        debugPrint('📊 ❌ Critical Error: $e');
        return {
          'users': 0,
          'authors': 0,
          'pending': 0,
          'books': 0,
          'published': 0,
        };
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F5),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Header with gradient and stats (fixed, won't scroll)
                  _buildHeader(),
                  // Tabs
                  _buildTabs(),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [_buildApplicationsTab(), _buildBooksTab()],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF9810FA), Color(0xFF8200DB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(bottom: BorderSide(color: Color(0xFFC27AFF), width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      child: Column(
        children: [
          // Title with icon
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Moderator Dashboard',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Kelola aplikasi dan sistem',
                      style: TextStyle(fontSize: 14, color: Colors.purple[100]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Stats cards - using StreamBuilder for real-time updates
          StreamBuilder<Map<String, int>>(
            stream: _statsStream(),
            builder: (context, snapshot) {
              debugPrint('📊 Stats Stream State: ${snapshot.connectionState}');
              debugPrint('📊 Has Data: ${snapshot.hasData}');
              debugPrint('📊 Stats Data: ${snapshot.data}');

              if (snapshot.hasError) {
                debugPrint('📊 Error: ${snapshot.error}');
              }

              final stats =
                  snapshot.data ??
                  {
                    'users': 0,
                    'authors': 0,
                    'pending': 0,
                    'books': 0,
                    'published': 0,
                  };
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Users',
                          stats['users'].toString(),
                          Icons.people_outline,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Authors',
                          stats['authors'].toString(),
                          Icons.edit_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Pending',
                          stats['pending'].toString(),
                          Icons.schedule,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Books',
                          stats['books'].toString(),
                          Icons.menu_book_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildStatCard(
                    'Published',
                    stats['published'].toString(),
                    Icons.check_circle_outline,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.9)),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFECECF0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: const Color(0xFF0A0A0A),
        unselectedLabelColor: const Color(0xFF0A0A0A),
        labelStyle: const TextStyle(fontSize: 14),
        tabs: const [
          Tab(icon: Icon(Icons.person_outline, size: 16), text: 'Applications'),
          Tab(icon: Icon(Icons.menu_book_outlined, size: 16), text: 'Books'),
        ],
      ),
    );
  }

  Widget _buildApplicationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Pending Applications',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF101828),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _applicationService.getPendingApplicationsStream(),
            builder: (context, snapshot) {
              // Debug logging
              debugPrint(
                '📊 Applications Stream State: ${snapshot.connectionState}',
              );
              debugPrint('📊 Has Data: ${snapshot.hasData}');
              debugPrint('📊 Data Length: ${snapshot.data?.length ?? 0}');
              debugPrint('📊 Has Error: ${snapshot.hasError}');
              if (snapshot.hasError) {
                debugPrint('📊 Error: ${snapshot.error}');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE9D4FF)),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                );
              }

              final applications = snapshot.data ?? [];

              if (applications.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE9D4FF)),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text(
                      'No pending applications',
                      style: TextStyle(color: Color(0xFF6A7282)),
                    ),
                  ),
                );
              }

              return Column(
                children: applications
                    .map((app) => _buildApplicationCard(app))
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 32),
          const Center(
            child: Text(
              'Recently Reviewed',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF101828),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          _buildRecentlyReviewed(),
        ],
      ),
    );
  }

  Widget _buildApplicationCard(Map<String, dynamic> application) {
    final appliedAt = _parseDate(application['appliedAt']);
    final dateStr = DateFormat('dd MMM yyyy').format(appliedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE9D4FF)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          // Badge
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF0B100).withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.schedule, size: 12, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'Pending',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Avatar
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(application['userId'])
                .get(),
            builder: (context, userSnapshot) {
              // Try to get name from application first, then from user document
              String displayName = application['userName'] ?? 'User';

              if (userSnapshot.hasData && userSnapshot.data != null) {
                final userData =
                    userSnapshot.data!.data() as Map<String, dynamic>?;
                displayName =
                    userData?['name'] ?? application['userName'] ?? 'User';
              }

              final initial = displayName.isNotEmpty
                  ? displayName[0].toUpperCase()
                  : 'U';

              return Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.purple[100]!, width: 3),
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Color(0xFF8200DB),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFF101828),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: Color(0xFF6A7282),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateStr,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6A7282),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          // Details - Get from applicationData map
          Builder(
            builder: (context) {
              final appData =
                  application['applicationData'] as Map<String, dynamic>?;
              final bio = appData?['bio'] ?? '-';
              final experience = appData?['experience'] ?? '-';
              final motivation = appData?['motivation'] ?? '-';

              return Column(
                children: [
                  _buildDetailRow('Bio', bio, Icons.person),
                  const SizedBox(height: 12),
                  _buildDetailRow('Experience', experience, Icons.work_outline),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    'Motivation',
                    motivation,
                    Icons.lightbulb_outline,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          // Action buttons
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _approveApplication(application),
                  icon: const Icon(Icons.check_circle_outline, size: 16),
                  label: const Text('Approve as Author'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A63E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _rejectApplication(application),
                  icon: const Icon(Icons.cancel_outlined, size: 16),
                  label: const Text('Reject'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE7000B),
                    side: const BorderSide(color: Color(0xFFE7000B)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF4A5565)),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Color(0xFF4A5565)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14, color: Color(0xFF364153)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentlyReviewed() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('author_applications')
          .where('status', whereIn: ['approved', 'rejected'])
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                'No reviews yet',
                style: TextStyle(color: Color(0xFF6A7282)),
              ),
            ),
          );
        }

        // Sort manually in memory to avoid composite index requirement
        final docs = snapshot.data!.docs.toList();
        docs.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;

          final aTime = _parseDate(aData['reviewedAt']);
          final bTime = _parseDate(bData['reviewedAt']);

          return bTime.compareTo(aTime); // descending (newest first)
        });

        // Take only first 5
        final limitedDocs = docs.take(5).toList();

        return Column(
          children: limitedDocs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final status = data['status'];
            final reviewedAt = _parseDate(data['reviewedAt']);
            final dateStr = DateFormat('dd MMM yyyy').format(reviewedAt);

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(data['userId'])
                  .get(),
              builder: (context, userSnapshot) {
                String displayName = 'User';
                if (userSnapshot.hasData &&
                    userSnapshot.data != null &&
                    userSnapshot.data!.exists) {
                  final userData =
                      userSnapshot.data!.data() as Map<String, dynamic>?;
                  displayName =
                      userData?['name'] ?? userData?['email'] ?? 'User';
                }

                final initial = displayName.isNotEmpty
                    ? displayName[0].toUpperCase()
                    : 'U';

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF3F3F5),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            initial,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF364153),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF101828),
                              ),
                            ),
                            Text(
                              dateStr,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6A7282),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: status == 'approved'
                              ? const Color(0xFF00A63E)
                              : const Color(0xFFE7000B),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status == 'approved' ? 'Accepted' : 'Rejected',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildBooksTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Pending Book Submissions',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF101828),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('published_books')
                .where('status', isEqualTo: 'pending')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFFFF085)),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text(
                      'No pending book submissions',
                      style: TextStyle(color: Color(0xFF6A7282)),
                    ),
                  ),
                );
              }

              // Sort manually in memory to avoid composite index requirement
              final docs = snapshot.data!.docs.toList();
              docs.sort((a, b) {
                final aData = a.data() as Map<String, dynamic>;
                final bData = b.data() as Map<String, dynamic>;

                final aTime = _parseDate(aData['createdAt']);
                final bTime = _parseDate(bData['createdAt']);

                return bTime.compareTo(aTime); // descending (newest first)
              });

              return Column(
                children: docs
                    .map(
                      (doc) => _buildBookCard(
                        doc.data() as Map<String, dynamic>,
                        doc.id,
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 32),
          const Center(
            child: Text(
              'Recently Reviewed Books',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF101828),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          _buildRecentlyReviewedBooks(),
        ],
      ),
    );
  }

  Widget _buildRecentlyReviewedBooks() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('published_books')
          .where('status', whereIn: ['published', 'rejected'])
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                'No reviews yet',
                style: TextStyle(color: Color(0xFF6A7282)),
              ),
            ),
          );
        }

        // Sort manually in memory to avoid composite index requirement
        final docs = snapshot.data!.docs.toList();
        docs.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;

          final aTime = _parseDate(aData['reviewedAt'] ?? aData['publishedAt']);
          final bTime = _parseDate(bData['reviewedAt'] ?? bData['publishedAt']);

          return bTime.compareTo(aTime); // descending (newest first)
        });

        // Take only first 5
        final limitedDocs = docs.take(5).toList();

        return Column(
          children: limitedDocs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final status = data['status'];
            final reviewedAt = _parseDate(
              data['reviewedAt'] ?? data['publishedAt'],
            );
            final dateStr = DateFormat('dd MMM yyyy').format(reviewedAt);

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  // Book cover thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      data['coverUrl'] ??
                          'https://via.placeholder.com/300x450/9810FA/FFFFFF?text=Book+Cover',
                      width: 40,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 40,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.book, size: 20),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['title'] ?? 'Untitled',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF101828),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'by ${data['author'] ?? 'Unknown'}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6A7282),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateStr,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF9AA0A6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: status == 'published'
                          ? const Color(0xFFD1FAE5)
                          : const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      status == 'published' ? 'Approved' : 'Rejected',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: status == 'published'
                            ? const Color(0xFF008236)
                            : const Color(0xFFDC2626),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildBookCard(Map<String, dynamic> book, String bookId) {
    final createdAt = _parseDate(book['createdAt']);
    final dateStr = DateFormat('dd MMM yyyy').format(createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFFFF085)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          // Badge
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF0B100).withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.schedule, size: 12, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'Pending',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Book cover
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              book['coverUrl'] ??
                  'https://via.placeholder.com/300x450/9810FA/FFFFFF?text=Book+Cover',
              width: 128,
              height: 192,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 128,
                  height: 192,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.book, size: 48),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Book details
          Text(
            book['title'] ?? 'Untitled',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF101828),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.person_outline,
                size: 14,
                color: Color(0xFF4A5565),
              ),
              const SizedBox(width: 4),
              Text(
                book['author'] ?? 'Unknown Author',
                style: const TextStyle(fontSize: 14, color: Color(0xFF4A5565)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Description
          Text(
            book['description'] ?? 'No description',
            style: const TextStyle(fontSize: 14, color: Color(0xFF364153)),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Tags
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              if (book['genre'] != null) _buildTag(book['genre'], null),
              if (book['pdfPages'] != null)
                _buildTag('${book['pdfPages']} pages', Icons.description),
              _buildTag(dateStr, Icons.calendar_today),
            ],
          ),
          const SizedBox(height: 16),
          // Action buttons
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _approveBook(bookId),
                  icon: const Icon(Icons.check_circle_outline, size: 16),
                  label: const Text('Approve & Publish'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A63E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _rejectBook(bookId),
                  icon: const Icon(Icons.cancel_outlined, size: 16),
                  label: const Text('Reject'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE7000B),
                    side: const BorderSide(color: Color(0xFFE7000B)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, IconData? icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: const Color(0xFF0A0A0A)),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: const TextStyle(fontSize: 12, color: Color(0xFF0A0A0A)),
          ),
        ],
      ),
    );
  }

  Future<void> _approveApplication(Map<String, dynamic> application) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final moderatorId = authProvider.currentUser?.id;

      if (moderatorId == null) return;

      await _applicationService.approveApplication(
        application['id'],
        moderatorId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application approved successfully'),
            backgroundColor: Color(0xFF00A63E),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _rejectApplication(Map<String, dynamic> application) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final moderatorId = authProvider.currentUser?.id;

      if (moderatorId == null) return;

      await _applicationService.rejectApplication(
        application['id'],
        moderatorId,
        'Does not meet requirements',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application rejected'),
            backgroundColor: Color(0xFFE7000B),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _approveBook(String bookId) async {
    try {
      await FirebaseFirestore.instance
          .collection('published_books')
          .doc(bookId)
          .update({
            'status': 'published',
            'publishedAt': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Book approved and published'),
            backgroundColor: Color(0xFF00A63E),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _rejectBook(String bookId) async {
    try {
      await FirebaseFirestore.instance
          .collection('published_books')
          .doc(bookId)
          .update({
            'status': 'rejected',
            'rejectedAt': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Book rejected'),
            backgroundColor: Color(0xFFE7000B),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
