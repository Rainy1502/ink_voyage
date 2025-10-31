import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/theme_provider.dart';
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
                await Provider.of<UserProvider>(
                  context,
                  listen: false,
                ).logout();
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

    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Scaffold(
          backgroundColor: isDark
              ? const Color(0xFF1A1625)
              : const Color(0xFFF3F3F5),
          body: SafeArea(
            child: Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                final user = userProvider.user;

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
                              // Dark Mode Card (overlaps header)
                              _buildDarkModeCard(context),

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

                              // Achievement Card
                              Consumer<BookProvider>(
                                builder: (context, bookProvider, child) {
                                  return _buildAchievementCard(
                                    context,
                                    bookProvider,
                                  );
                                },
                              ),

                              const SizedBox(height: 16),

                              // Logout Button
                              Builder(
                                builder: (context) {
                                  final isDark =
                                      Theme.of(context).brightness ==
                                      Brightness.dark;
                                  final logoutColor = isDark
                                      ? const Color(0xFFFF6467)
                                      : const Color(0xFFE7000B);

                                  return SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton(
                                      onPressed: () =>
                                          _showLogoutDialog(context),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                        ),
                                        backgroundColor: isDark
                                            ? const Color(
                                                0x4D262626,
                                              ) // Gray 30%
                                            : Colors.white,
                                        side: BorderSide(
                                          color: const Color(0xFFE7000B),
                                          width: 1.333,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.logout,
                                            size: 16,
                                            color: logoutColor,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Keluar',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal,
                                              color: logoutColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
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
      },
    );
  }

  Widget _buildHeader(BuildContext context, user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1A1625), Color(0xFF1A1625)],
              )
            : const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFAD46FF),
                  Color(0xFF9810FA),
                  Color(0xFF8200DB),
                ],
              ),
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0x3300D9FF) : const Color(0xFFDAB2FF),
            width: 1.162,
          ),
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
                  color: isDark
                      ? const Color(0x9900D9FF)
                      : Colors.black.withValues(alpha: 0.15),
                  blurRadius: isDark ? 16 : 8,
                  offset: Offset(0, isDark ? 2 : 4),
                ),
              ],
            ),
            child: Text(
              'Profil Saya',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.normal,
                color: isDark ? primaryColor : Colors.white,
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
                  border: Border.all(
                    color: isDark ? primaryColor : Colors.white,
                    width: 4,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: isDark
                          ? const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFF00D9FF), Color(0xFF00B8D4)],
                            )
                          : null,
                      color: isDark ? null : const Color(0xFF8200DB),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        user.initial,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.normal,
                          color: isDark
                              ? const Color(0xFF0D0711)
                              : Colors.white,
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
                      color: isDark
                          ? const Color(0x9900D9FF)
                          : Colors.black.withValues(alpha: 0.15),
                      blurRadius: isDark ? 16 : 8,
                      offset: Offset(0, isDark ? 2 : 4),
                    ),
                  ],
                ),
                child: Text(
                  user.name,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.normal,
                    color: isDark ? primaryColor : Colors.white,
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
                      color: isDark
                          ? const Color(0x6600D9FF)
                          : Colors.black.withValues(alpha: 0.12),
                      blurRadius: isDark ? 8 : 6,
                      offset: Offset(0, isDark ? 1 : 3),
                    ),
                  ],
                ),
                child: Text(
                  user.email,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: isDark ? Colors.white : const Color(0xFFEDCCFF),
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

  Widget _buildDarkModeCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(17.333, 17.333, 1.333, 18.667),
      decoration: BoxDecoration(
        color: isDark ? surfaceColor : Colors.white,
        border: Border.all(
          color: isDark
              ? const Color(0x3300D9FF)
              : Colors.black.withValues(alpha: 0.1),
          width: 1.162,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return Row(
            children: [
              // Icon
              Icon(
                Icons.dark_mode_outlined,
                size: 20,
                color: isDark ? primaryColor : const Color(0xFF8200DB),
              ),

              const SizedBox(width: 12),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dark Mode',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: isDark ? primaryColor : const Color(0xFF0A0A0A),
                        height: 1.5,
                      ),
                    ),
                    Text(
                      themeProvider.isDarkMode
                          ? 'Mode malam aktif'
                          : 'Mode siang aktif',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: isDark
                            ? const Color(0x9900D9FF)
                            : const Color(0xFF6A7282),
                        height: 1.43,
                      ),
                    ),
                  ],
                ),
              ),

              // Button
              Container(
                height: 32,
                padding: const EdgeInsets.symmetric(
                  horizontal: 13.333,
                  vertical: 1.333,
                ),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A0F2E) : Colors.white,
                  border: Border.all(
                    color: isDark
                        ? const Color(0x6600D9FF)
                        : Colors.black.withValues(alpha: 0.1),
                    width: 1.162,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextButton(
                  onPressed: () {
                    themeProvider.toggleTheme();
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    themeProvider.isDarkMode ? 'Light' : 'Dark',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: isDark ? primaryColor : const Color(0xFF0A0A0A),
                      height: 1.43,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
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
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final surfaceColor = Theme.of(context).colorScheme.surface;

        // Tentukan warna berdasarkan label dan mode
        Color getColorForLabel() {
          if (isDark) {
            if (label == 'Total Buku' || label == 'Halaman Dibaca') {
              return const Color(0xFF00D9FF); // Cyan
            } else if (label == 'Sedang Dibaca') {
              return const Color(0xFF7B3FF2); // Purple
            } else if (label == 'Selesai') {
              return const Color(0xFFB967FF); // Light purple
            }
          }
          return const Color(0xFF8200DB); // Default purple for light mode
        }

        final cardColor = getColorForLabel();

        return Container(
          height: 134.667,
          padding: const EdgeInsets.all(1.333),
          decoration: BoxDecoration(
            color: isDark ? surfaceColor : Colors.white,
            border: Border.all(
              color: isDark
                  ? cardColor.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.1),
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
                  style: TextStyle(
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
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: isDark
                        ? cardColor.withValues(alpha: 0.6)
                        : const Color(0xFF6A7282),
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
      },
    );
  }

  Widget _buildAccountInfoCard(BuildContext context, user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(1.333),
      decoration: BoxDecoration(
        color: isDark ? surfaceColor : Colors.white,
        border: Border.all(
          color: isDark
              ? const Color(0x3300D9FF)
              : Colors.black.withValues(alpha: 0.1),
          width: 1.162,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Title
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Text(
              'Informasi Akun',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: isDark ? primaryColor : const Color(0xFF0A0A0A),
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
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final primaryColor = Theme.of(context).colorScheme.primary;

        return Row(
          children: [
            Container(
              width: 38.667,
              height: 38.667,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0x1A00D9FF)
                    : const Color(0xFFEDCCFF),
                border: Border.all(
                  color: isDark
                      ? const Color(0x4D00D9FF)
                      : const Color(0xFFDAB2FF),
                  width: 1.162,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 20,
                  color: isDark ? primaryColor : const Color(0xFF8200DB),
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: isDark
                          ? const Color(0x9900D9FF)
                          : const Color(0xFF6A7282),
                      height: 1.43,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: isDark ? Colors.white : const Color(0xFF101828),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAchievementCard(
    BuildContext context,
    BookProvider bookProvider,
  ) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final surfaceColor = Theme.of(context).colorScheme.surface;
        const tertiaryColor = Color(0xFFB967FF); // Light purple for achievement

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(1.333),
          decoration: BoxDecoration(
            color: isDark ? surfaceColor : Colors.white,
            border: Border.all(
              color: isDark
                  ? const Color(0x33B967FF) // Light purple 20%
                  : Colors.black.withValues(alpha: 0.1),
              width: 1.333,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pencapaian Membaca',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: isDark ? tertiaryColor : const Color(0xFF0A0A0A),
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Progress membaca Anda sejauh ini',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: isDark
                            ? const Color(0xB3B967FF) // Light purple 70%
                            : const Color(0xFF717182),
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
                    color: isDark
                        ? const Color(0x1AB967FF) // Light purple 10%
                        : const Color(0xFFEDCCFF),
                    border: Border.all(
                      color: isDark
                          ? const Color(0x4DB967FF) // Light purple 30%
                          : const Color(0xFFE9D4FF),
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
                            Text(
                              'Pembaca Aktif',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF101828),
                                height: 1.5,
                              ),
                            ),
                            Text(
                              '${bookProvider.completedCount} buku selesai',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: isDark
                                    ? const Color(
                                        0xB3B967FF,
                                      ) // Light purple 70%
                                    : const Color(0xFF9810FA),
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
      },
    );
  }
}
