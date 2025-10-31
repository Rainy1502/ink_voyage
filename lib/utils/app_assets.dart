/// Application asset paths
///
/// This class provides centralized access to all image and icon assets
/// downloaded from the Figma design.
class AppAssets {
  // Base paths
  static const String _basePath = 'assets/images';
  static const String _iconsPath = '$_basePath/icons';
  static const String _sampleBooksPath = '$_basePath/sample_books';

  // Main Images
  static const String appLogo = '$_basePath/app_logo.png';

  // Sample Book Covers
  static const String bookCoverCrimeAndPunishment =
      '$_sampleBooksPath/book_cover_crime_and_punishment.png';

  // Navigation Icons
  static const String navBooksIcon = '$_iconsPath/nav_books_icon.svg';
  static const String navProgressIcon = '$_iconsPath/nav_progress_icon.svg';
  static const String navProfileIcon = '$_iconsPath/nav_profile_icon.svg';

  // Profile Stats Icons
  static const String totalBooksIcon = '$_iconsPath/total_books_icon.svg';
  static const String readingIcon = '$_iconsPath/reading_icon.svg';
  static const String completedIcon = '$_iconsPath/completed_icon.svg';
  static const String pagesReadIcon = '$_iconsPath/pages_read_icon.svg';

  // User Profile Icons
  static const String userIcon = '$_iconsPath/user_icon.svg';
  static const String emailIcon = '$_iconsPath/email_icon.svg';
  static const String calendarIcon = '$_iconsPath/calendar_icon.svg';

  // Feature Icons
  static const String achievementIcon = '$_iconsPath/achievement_icon.svg';
  static const String darkModeIcon = '$_iconsPath/dark_mode_icon.svg';
  static const String logoutIcon = '$_iconsPath/logout_icon.svg';

  // Chart Icons
  static const String chartBackground = '$_iconsPath/chart_background.svg';
  static const String chartLegendIcon = '$_iconsPath/chart_legend_icon.svg';

  // Action Icons
  static const String closeIcon = '$_iconsPath/close_icon.svg';

  // Sample book covers list (for testing/demo)
  static const List<String> sampleBookCovers = [bookCoverCrimeAndPunishment];
}
