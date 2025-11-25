import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/icon_helper.dart';
import '../providers/auth_provider.dart';
import 'author_dashboard_screen.dart';
import 'book_list_screen.dart';
import 'discover_screen.dart';
import 'progress_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  List<Widget> _getScreens(bool isAuthor) {
    if (isAuthor) {
      return const [
        AuthorDashboardScreen(),
        DiscoverScreen(),
        BookListScreen(),
        ProgressScreen(),
        ProfileScreen(),
      ];
    }
    return const [
      DiscoverScreen(),
      BookListScreen(),
      ProgressScreen(),
      ProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Helpful debug: show mapping at runtime when navigation item tapped
  void _onItemTappedWithLog(int index) {
    final authProvider = context.read<AuthProvider>();
    final isAuthor = authProvider.currentUser?.role == 'author';

    final labels = isAuthor
        ? ['Dashboard', 'Discover', 'Daftar Buku', 'Progress', 'Profil']
        : ['Discover', 'Daftar Buku', 'Progress', 'Profil'];
    final label = (index >= 0 && index < labels.length)
        ? labels[index]
        : 'unknown';
    debugPrint('BottomNav tapped: index=$index label=$label');
    _onItemTapped(index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final isAuthor = authProvider.currentUser?.role == 'author';
    final screens = _getScreens(isAuthor);

    // Reset index if out of bounds (e.g., after role change from author to reader)
    if (_selectedIndex >= screens.length) {
      _selectedIndex = 0;
    }

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTappedWithLog,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        type: BottomNavigationBarType.fixed,
        items: [
          if (isAuthor)
            BottomNavigationBarItem(
              icon: AppIcons.navDashboard(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              activeIcon: AppIcons.navDashboard(
                color: theme.colorScheme.primary,
              ),
              label: 'Dashboard',
            ),
          BottomNavigationBarItem(
            icon: AppIcons.navDiscover(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            activeIcon: AppIcons.navDiscover(color: theme.colorScheme.primary),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: AppIcons.navBooks(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            activeIcon: AppIcons.navBooks(color: theme.colorScheme.primary),
            label: 'Daftar Buku',
          ),
          BottomNavigationBarItem(
            icon: AppIcons.navProgress(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            activeIcon: AppIcons.navProgress(color: theme.colorScheme.primary),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: AppIcons.navProfile(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            activeIcon: AppIcons.navProfile(color: theme.colorScheme.primary),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
