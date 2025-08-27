import 'package:flutter/material.dart';

class AppColors {
  static const Color primary =
      Color(0xFF8B4513); // Saddle Brown - representing African earth
  static const Color primaryDark = Color(0xFF5D2F0B); // Darker brown
  static const Color primaryLight = Color(0xFFD2691E); // Chocolate orange

  static const Color secondary =
      Color(0xFFFF8C00); // Dark orange - vibrant African sunset
  static const Color secondaryDark = Color(0xFFCC7000);
  static const Color secondaryLight = Color(0xFFFFB347);

  static const Color accent =
      Color(0xFFFF8F00); // Amber - warm and user-friendly
  static const Color accentDark = Color(0xFFE65100);
  static const Color accentLight = Color(0xFFFFC947);

  // Neutral colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFE57373);
  static const Color success = Color(0xFF66BB6A);
  static const Color warning = Color(0xFFFFB74D);
  static const Color info = Color(0xFF42A5F5);

  // Additional neutral shades
  static const Color grey = Color(0xFF9E9E9E);
  static const Color greyLight = Color(0xFFE0E0E0);
  static const Color greyDark = Color(0xFF616161);

  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFFFFFFFF);

  // Border colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFEEEEEE);
  static const Color borderDark = Color(0xFFBDBDBD);

  // Shadow colors
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0D000000);
  static const Color shadowDark = Color(0x33000000);

  // African-inspired colors
  static const Color safariGreen = Color(0xFF228B22); // Forest Green
  static const Color safariRed = Color(0xFFDC143C); // Crimson
  static const Color safariYellow = Color(0xFFFFD700); // Gold
  static const Color terracotta = Color(0xFFE2725B); // African clay
  static const Color baobabBrown = Color(0xFF8B4513); // Baobab tree bark

  // Gradient colors
  static const List<Color> primaryGradient = [primary, primaryDark];
  static const List<Color> secondaryGradient = [secondary, secondaryDark];
  static const List<Color> sunsetGradient = [
    Color(0xFFFF8C00),
    Color(0xFFFFD700)
  ];
  static const List<Color> earthGradient = [
    Color(0xFF8B4513),
    Color(0xFFD2691E)
  ];
}
