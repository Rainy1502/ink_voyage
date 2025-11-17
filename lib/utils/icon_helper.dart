import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppIcons {
  // Navigation Icons
  static Widget navBooks({Color? color, double size = 24}) {
    return SvgPicture.asset(
      'assets/images/icons/nav_books_icon.svg',
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  static Widget navProgress({Color? color, double size = 24}) {
    return SvgPicture.asset(
      'assets/images/icons/nav_progress_icon.svg',
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  static Widget navProfile({Color? color, double size = 24}) {
    return SvgPicture.asset(
      'assets/images/icons/nav_profile_icon.svg',
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  static Widget navDiscover({Color? color, double size = 24}) {
    // No SVG asset for discover yet; use built-in icon so feature is available.
    return Icon(Icons.explore, size: size, color: color ?? Colors.black);
  }

  // Profile Stats Icons
  static Widget totalBooks({Color? color, double size = 32}) {
    return SvgPicture.asset(
      'assets/images/icons/total_books_icon.svg',
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  static Widget reading({Color? color, double size = 32}) {
    return SvgPicture.asset(
      'assets/images/icons/reading_icon.svg',
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  static Widget completed({Color? color, double size = 32}) {
    return SvgPicture.asset(
      'assets/images/icons/completed_icon.svg',
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  static Widget pagesRead({Color? color, double size = 32}) {
    return SvgPicture.asset(
      'assets/images/icons/pages_read_icon.svg',
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  // Profile Info Icons
  static Widget user({Color? color, double size = 24}) {
    return SvgPicture.asset(
      'assets/images/icons/user_icon.svg',
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  static Widget email({Color? color, double size = 24}) {
    return SvgPicture.asset(
      'assets/images/icons/email_icon.svg',
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  static Widget calendar({Color? color, double size = 24}) {
    return SvgPicture.asset(
      'assets/images/icons/calendar_icon.svg',
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  // Action Icons
  static Widget darkMode({Color? color, double size = 20}) {
    return SvgPicture.asset(
      'assets/images/icons/dark_mode_icon.svg',
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  static Widget achievement({Color? color, double size = 32}) {
    return SvgPicture.asset(
      'assets/images/icons/achievement_icon.svg',
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  static Widget logout({Color? color, double size = 20}) {
    return SvgPicture.asset(
      'assets/images/icons/logout_icon.svg',
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  static Widget close({Color? color, double size = 16}) {
    return SvgPicture.asset(
      'assets/images/icons/close_icon.svg',
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  // App Logo
  static Widget appLogo({double size = 120}) {
    return Image.asset('assets/images/app_logo.png', width: size, height: size);
  }

  // Main Logo (Logo.png)
  static Widget mainLogo({double size = 120}) {
    return Image.asset('assets/images/Logo.png', width: size, height: size);
  }

  // Chart Background
  static Widget chartBackground({double? width, double? height}) {
    return SvgPicture.asset(
      'assets/images/icons/chart_background.svg',
      width: width,
      height: height,
    );
  }
}
