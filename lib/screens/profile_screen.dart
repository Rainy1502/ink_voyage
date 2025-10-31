import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/book_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    // Set status bar color to match header gradient top
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFAD46FF), // Match gradient top color
        statusBarIconBrightness: Brightness.light, // White icons
        statusBarBrightness: Brightness.dark, // For iOS
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F5),
      body: SafeArea(
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
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 72),
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
