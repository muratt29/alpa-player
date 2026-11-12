import 'package:flutter/material.dart';

/// Alpa Player renkleri: lacivert + beyaz.
class AlpaColors {
  static const navy = Color(0xFF0B1F4B);
  static const navyLight = Color(0xFF1A3A7A);
  static const navyDark = Color(0xFF07142F);
  static const white = Colors.white;
  static const surface = Color(0xFFF4F6FB); // cok acik mavi-gri zemin
}

ThemeData buildAlpaTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AlpaColors.navy,
    brightness: Brightness.light,
  ).copyWith(
    primary: AlpaColors.navy,
    onPrimary: AlpaColors.white,
    secondary: AlpaColors.navyLight,
    onSecondary: AlpaColors.white,
    surface: AlpaColors.white,
    onSurface: AlpaColors.navyDark,
  );

  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: AlpaColors.navy.withValues(alpha: 0.25)),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AlpaColors.surface,
    appBarTheme: const AppBarTheme(
      backgroundColor: AlpaColors.navy,
      foregroundColor: AlpaColors.white,
      centerTitle: false,
      elevation: 0,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AlpaColors.navy,
      indicatorColor: AlpaColors.white.withValues(alpha: 0.18),
      iconTheme: WidgetStateProperty.all(
          const IconThemeData(color: AlpaColors.white)),
      labelTextStyle: WidgetStateProperty.all(
          const TextStyle(color: AlpaColors.white, fontSize: 12)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AlpaColors.navy,
        foregroundColor: AlpaColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AlpaColors.white,
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: AlpaColors.navy, width: 2),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      tileColor: AlpaColors.white,
      iconColor: AlpaColors.navy,
    ),
    progressIndicatorTheme:
        const ProgressIndicatorThemeData(color: AlpaColors.navy),
  );
}
