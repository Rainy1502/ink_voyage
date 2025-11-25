import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:fl_chart/fl_chart.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  Map<String, dynamic> _analyticsData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }

  Future<void> _loadAnalyticsData() async {
    try {
      final currentUserId =
          firebase_auth.FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) return;

      // Fetch published books by current author
      final booksSnapshot = await FirebaseFirestore.instance
          .collection('published_books')
          .where('authorId', isEqualTo: currentUserId)
          .get();

      int totalViews = 0;
      int totalReaders = 0;
      int publishedBooks = booksSnapshot.docs.length;
      double totalRating = 0;
      int ratingCount = 0;
      Map<String, int> genreDistribution = {};

      for (var doc in booksSnapshot.docs) {
        final data = doc.data();
        totalViews += (data['views'] ?? 0) as int;
        totalReaders += (data['readers'] ?? 0) as int;

        final rating = (data['rating'] ?? 0.0) as num;
        final ratings = (data['ratingsCount'] ?? 0) as int;
        totalRating += rating.toDouble() * ratings;
        ratingCount += ratings;

        final genre = data['genre'] ?? 'Unknown';
        genreDistribution[genre] = (genreDistribution[genre] ?? 0) + 1;
      }

      double avgRating = ratingCount > 0 ? totalRating / ratingCount : 0;

      setState(() {
        _analyticsData = {
          'totalViews': totalViews,
          'totalReaders': totalReaders,
          'publishedBooks': publishedBooks,
          'avgRating': avgRating,
          'genreDistribution': genreDistribution,
          'avgViewsPerBook': publishedBooks > 0
              ? totalViews / publishedBooks.toDouble()
              : 0.0,
          'readerConversion': totalViews > 0
              ? (totalReaders / totalViews.toDouble() * 100)
              : 0.0,
        };
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading analytics: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [theme.colorScheme.primary, const Color(0xFF8200DB)],
            stops: const [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context, theme),

              // Content
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(color: Color(0xFFF3F3F5)),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              const SizedBox(height: 12),
                              _buildStatsGrid(),
                              const SizedBox(height: 24),
                              _buildMonthlyPerformanceCard(),
                              const SizedBox(height: 24),
                              _buildGenreDistributionCard(),
                              const SizedBox(height: 24),
                              _buildPerformanceInsightsCard(),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, const Color(0xFF8200DB)],
        ),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFC27AFF), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.2,
              ),
            ),
            child: const Icon(
              Icons.analytics_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),

          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analytics Dashboard',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Detailed performance metrics',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFE9D5FF),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Back button
          Container(
            width: 46,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.2,
              ),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 16),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return SizedBox(
      height: 209,
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.82,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildStatCard(
            'Total Views',
            '${_analyticsData['totalViews'] ?? 0}',
            Icons.visibility_outlined,
            const Color(0xFF6A7282),
          ),
          _buildStatCard(
            'Total Readers',
            '${_analyticsData['totalReaders'] ?? 0}',
            Icons.people_outline,
            const Color(0xFF6A7282),
          ),
          _buildStatCard(
            'Published Books',
            '${_analyticsData['publishedBooks'] ?? 0}',
            Icons.menu_book_outlined,
            const Color(0xFF6A7282),
          ),
          _buildStatCard(
            'Avg Rating',
            (_analyticsData['avgRating'] ?? 0.0).toStringAsFixed(1),
            Icons.star_outline,
            const Color(0xFF6A7282),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.1),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.normal,
                ),
              ),
              Icon(icon, size: 18, color: color),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF101828),
              fontSize: 18,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyPerformanceCard() {
    return Container(
      padding: const EdgeInsets.all(1.2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.1),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Monthly Performance',
                  style: TextStyle(
                    color: Color(0xFF101828),
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Views dan pembaca dalam 6 bulan terakhir',
                  style: TextStyle(color: Color(0xFF717182), fontSize: 16),
                ),
              ],
            ),
          ),
          Container(
            height: 300,
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 0.25,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withValues(alpha: 0.2),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withValues(alpha: 0.2),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        const months = [
                          'Jan',
                          'Feb',
                          'Mar',
                          'Apr',
                          'May',
                          'Jun',
                        ];
                        if (value.toInt() >= 0 &&
                            value.toInt() < months.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              months[value.toInt()],
                              style: const TextStyle(
                                color: Color(0xFF888888),
                                fontSize: 12,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 0.25,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(value == value.toInt() ? 0 : 2),
                          style: const TextStyle(
                            color: Color(0xFF888888),
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                minX: 0,
                maxX: 5,
                minY: 0,
                maxY: 1,
                lineBarsData: [
                  // Views line (cyan)
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 0),
                      FlSpot(1, 0),
                      FlSpot(2, 0),
                      FlSpot(3, 1),
                      FlSpot(4, 1),
                      FlSpot(5, 1),
                    ],
                    isCurved: true,
                    color: const Color(0xFF00D9FF),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                  ),
                  // Readers line (purple)
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 0),
                      FlSpot(1, 0),
                      FlSpot(2, 0),
                      FlSpot(3, 0.8),
                      FlSpot(4, 0.8),
                      FlSpot(5, 0.8),
                    ],
                    isCurved: true,
                    color: const Color(0xFFB967FF),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreDistributionCard() {
    final genreDistribution =
        _analyticsData['genreDistribution'] as Map<String, int>? ?? {};
    final total = genreDistribution.values.fold(
      0,
      (accumulator, value) => accumulator + value,
    );

    return Container(
      padding: const EdgeInsets.all(1.2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.1),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Genre Distribution',
                  style: TextStyle(
                    color: Color(0xFF101828),
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Distribusi buku berdasarkan genre',
                  style: TextStyle(color: Color(0xFF717182), fontSize: 16),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 250,
            child: total > 0
                ? Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 200,
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              sections: _buildPieChartSections(
                                genreDistribution,
                                total,
                              ),
                              sectionsSpace: 2,
                              centerSpaceRadius: 0,
                            ),
                          ),
                        ),
                        // Labels
                        if (genreDistribution.length == 1)
                          Positioned(
                            bottom: 20,
                            child: Text(
                              '${genreDistribution.keys.first} 100%',
                              style: const TextStyle(
                                color: Color(0xFFB967FF),
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                : const Center(
                    child: Text(
                      'Belum ada data',
                      style: TextStyle(color: Color(0xFF6A7282), fontSize: 14),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
    Map<String, int> genreDistribution,
    int total,
  ) {
    final colors = [
      const Color(0xFFB967FF),
      const Color(0xFF00D9FF),
      const Color(0xFF00A63E),
      const Color(0xFFFB2C36),
      const Color(0xFFFFB800),
    ];

    int colorIndex = 0;
    return genreDistribution.entries.map((entry) {
      final percentage = (entry.value / total * 100);
      final color = colors[colorIndex % colors.length];
      colorIndex++;

      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${entry.key}\n${percentage.toStringAsFixed(0)}%',
        color: color,
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildPerformanceInsightsCard() {
    final avgViewsPerBook = _analyticsData['avgViewsPerBook'] ?? 0;
    final readerConversion = _analyticsData['readerConversion'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(1.2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.1),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Performance Insights',
                  style: TextStyle(
                    color: Color(0xFF101828),
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ringkasan performa buku Anda',
                  style: TextStyle(color: Color(0xFF717182), fontSize: 16),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              children: [
                _buildInsightItem(
                  Icons.trending_up,
                  'Growth Rate',
                  '+24% dari bulan lalu',
                  '↑ 24%',
                  const Color(0xFF00A63E),
                ),
                const SizedBox(height: 16),
                _buildInsightItem(
                  Icons.visibility_outlined,
                  'Avg Views per Book',
                  'Rata-rata engagement',
                  avgViewsPerBook.toStringAsFixed(0),
                  const Color(0xFF101828),
                ),
                const SizedBox(height: 16),
                _buildInsightItem(
                  Icons.people_outline,
                  'Reader Conversion',
                  'View to reader ratio',
                  '${readerConversion.toStringAsFixed(1)}%',
                  const Color(0xFF101828),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(
    IconData icon,
    String title,
    String subtitle,
    String value,
    Color valueColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF6A7282)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF101828),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF6A7282),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
