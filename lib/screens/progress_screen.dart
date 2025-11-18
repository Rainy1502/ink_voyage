import 'dart:io';
import 'package:flutter/material.dart';
// 'flutter/services.dart' not needed; material.dart already exports system services
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/book_provider.dart';
import '../models/book_model.dart';
import 'update_progress_screen.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use AppBar + extendBodyBehindAppBar to let the header gradient draw behind the status bar
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      backgroundColor: const Color(0xFFF3F3F5),
      body: SafeArea(
        top: false,
        child: Consumer<BookProvider>(
          builder: (context, provider, child) {
            final totalPages = provider.books.fold<int>(
              0,
              (sum, book) => sum + book.totalPages,
            );
            final completedBooks = provider.books
                .where((book) => book.status == 'completed')
                .toList();
            final readingBooks = provider.books
                .where((book) => book.status == 'reading')
                .toList();

            return Column(
              children: [
                // Header with gradient
                _buildHeader(context, totalPages, completedBooks.length),

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Statistics Chart
                        _buildStatisticsCard(context, provider),

                        const SizedBox(height: 24),

                        // Currently Reading Section
                        if (readingBooks.isNotEmpty) ...[
                          const Text(
                            'Sedang Dibaca',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.normal,
                              color: Color(0xFF0A0A0A),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...readingBooks.map(
                            (book) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildReadingBookCard(context, book),
                            ),
                          ),
                        ],

                        const SizedBox(height: 12),

                        // Completed Books Section
                        if (completedBooks.isNotEmpty) ...[
                          const Text(
                            'Buku yang Sudah Selesai',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.normal,
                              color: Color(0xFF0A0A0A),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...completedBooks.map(
                            (book) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildCompletedBookCard(context, book),
                            ),
                          ),
                        ],

                        const SizedBox(height: 80), // Bottom navigation padding
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    int totalPages,
    int completedCount,
  ) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFAD46FF), Color(0xFF9810FA), Color(0xFF8200DB)],
        ),
        border: Border(
          bottom: BorderSide(color: Color(0xFFC27AFF), width: 1.18),
        ),
      ),
      padding: EdgeInsets.fromLTRB(24, 50, 24, 16),
      child: Column(
        children: [
          // Title
          const Text(
            'Progress Membaca',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.normal,
              color: Colors.white,
              height: 1.33,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Stats Cards Row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(17.16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1.18,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Halaman',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.43,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        totalPages.toString(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.normal,
                          color: Colors.white,
                          height: 1.33,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 22),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(17.16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1.18,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Buku Selesai',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.43,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        completedCount.toString(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.normal,
                          color: Colors.white,
                          height: 1.33,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard(BuildContext context, BookProvider provider) {
    // Get monthly completion data for last 6 months
    final now = DateTime.now();
    final monthlyData = <String, int>{};

    // Initialize last 6 months
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthKey = _getMonthLabel(month.month);
      monthlyData[monthKey] = 0;
    }

    // Count completed books per month
    for (var book in provider.books) {
      if (book.status == 'completed' && book.updatedAt != null) {
        final monthKey = _getMonthLabel(book.updatedAt!.month);
        if (monthlyData.containsKey(monthKey)) {
          monthlyData[monthKey] = monthlyData[monthKey]! + 1;
        }
      }
    }

    return Container(
      padding: const EdgeInsets.all(1.18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.1),
          width: 1.18,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Statistik Membaca 6 Bulan Terakhir',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Color(0xFF0A0A0A),
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Grafik buku yang diselesaikan per bulan',
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

          const SizedBox(height: 24),

          // Chart
          SizedBox(
            height: 250,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY:
                      (monthlyData.values.isEmpty
                              ? 1
                              : monthlyData.values.reduce(
                                  (a, b) => a > b ? a : b,
                                ))
                          .toDouble() +
                      0.5,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final months = monthlyData.keys.toList();
                          if (value.toInt() >= 0 &&
                              value.toInt() < months.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                months[value.toInt()],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFB967FF),
                                ),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(value % 1 == 0 ? 0 : 2),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFB967FF),
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
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: const Color(0xFFB967FF).withValues(alpha: 0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(
                        color: const Color(0xFFB967FF).withValues(alpha: 0.3),
                        width: 1,
                      ),
                      left: BorderSide(
                        color: const Color(0xFFB967FF).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                  ),
                  barGroups: monthlyData.entries.toList().asMap().entries.map((
                    entry,
                  ) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.value.toDouble(),
                          color: const Color(0xFF7B3FF2),
                          width: 20,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          // Legend
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7B3FF2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Buku Selesai',
                  style: TextStyle(fontSize: 16, color: Color(0xFF7B3FF2)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingBookCard(BuildContext context, Book book) {
    final progress = book.totalPages > 0
        ? (book.currentPage / book.totalPages * 100).clamp(0, 100)
        : 0;

    return Container(
      padding: const EdgeInsets.all(1.18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.1),
          width: 1.18,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Book Cover
            Container(
              width: 128,
              height: 192,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: book.imageUrl.startsWith('http')
                    ? Image.network(
                        book.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFFF3F3F5),
                            child: const Icon(Icons.book, size: 64),
                          );
                        },
                      )
                    : Image.file(
                        File(book.imageUrl),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFFF3F3F5),
                            child: const Icon(Icons.book, size: 64),
                          );
                        },
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Book Title
            Text(
              book.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.normal,
                color: Color(0xFF0A0A0A),
                height: 1.56,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            // Author
            Text(
              'oleh ${book.author}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Color(0xFF717182),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // Status Badge
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9.18,
                  vertical: 3.18,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF9810FA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Sedang Dibaca',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                    height: 1.33,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Progress Section
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Progress',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF4A5565),
                        height: 1.43,
                      ),
                    ),
                    Text(
                      '${progress.toInt()}%',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF9810FA),
                        height: 1.43,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    minHeight: 8,
                    backgroundColor: const Color(
                      0xFF9810FA,
                    ).withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF9810FA),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Halaman ${book.currentPage}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6A7282),
                          height: 1.43,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'dari ${book.totalPages}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6A7282),
                          height: 1.43,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Update Progress Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          UpdateProgressScreen(bookId: book.id),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9810FA),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Update Progress',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedBookCard(BuildContext context, Book book) {
    return Container(
      padding: const EdgeInsets.all(1.18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.1),
          width: 1.18,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Book Cover
            Container(
              width: 128,
              height: 192,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: book.imageUrl.startsWith('http')
                    ? Image.network(
                        book.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFFF3F3F5),
                            child: const Icon(Icons.book, size: 64),
                          );
                        },
                      )
                    : Image.file(
                        File(book.imageUrl),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFFF3F3F5),
                            child: const Icon(Icons.book, size: 64),
                          );
                        },
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Book Title
            Text(
              book.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.normal,
                color: Color(0xFF0A0A0A),
                height: 1.56,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            // Author
            Text(
              'oleh ${book.author}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Color(0xFF717182),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // Status Badge
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9.18,
                  vertical: 3.18,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF00A63E),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Selesai',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                    height: 1.33,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Pages and Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    '${book.totalPages} halaman',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4A5565),
                      height: 1.43,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                // Rating Stars
                Row(
                  children: List.generate(
                    5,
                    (index) => Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Icon(
                        Icons.star,
                        size: 16,
                        color: index < (book.rating ?? 0)
                            ? Colors.amber
                            : Colors.grey.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Notes (if any)
            if (book.notes != null && book.notes!.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(13.16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F3F5),
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.1),
                    width: 1.18,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  book.notes!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4A5565),
                    height: 1.43,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getMonthLabel(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return months[month - 1];
  }
}
