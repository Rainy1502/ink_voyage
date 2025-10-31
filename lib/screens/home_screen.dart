import 'package:flutter/material.dart';
import '../utils/icon_helper.dart';
import 'book_list_screen.dart';
import 'progress_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    BookListScreen(),
    ProgressScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        type: BottomNavigationBarType.fixed,
        items: [
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
