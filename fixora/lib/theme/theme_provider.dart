import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}

class AppTheme {
  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF5F7FA);
  static const Color lightSurface = Colors.white;
  static const Color lightPrimary = Color(0xFF1e9dfd);
  static const Color lightSecondary = Color(0xFF1ab0ff);
  static const Color lightText = Color(0xFF1a1a1a);
  static const Color lightTextSecondary = Color(0xFF666666);

  // Dark Theme Colors (existing)
  static const Color darkBackground = Color(0xFF0c1626);
  static const Color darkSurface = Color(0xFF101d31);
  static const Color darkFieldColor = Color(0xFF16243a);
  static const Color darkPrimary = Color(0xFF1e9dfd);
  static const Color darkSecondary = Color(0xFF1ab0ff);
  static const Color darkText = Colors.white;
  static const Color darkTextSecondary = Color(0xFFB0B0B0);

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: lightPrimary,
    scaffoldBackgroundColor: lightBackground,
    colorScheme: const ColorScheme.light(
      primary: lightPrimary,
      secondary: lightSecondary,
      surface: lightSurface,
      background: lightBackground,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: lightSurface,
      foregroundColor: lightText,
      elevation: 0,
      iconTheme: IconThemeData(color: lightText),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: lightText, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: lightText, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(color: lightText, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: lightText, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(color: lightText, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: lightText, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: lightText),
      bodyMedium: TextStyle(color: lightTextSecondary),
    ),
    iconTheme: const IconThemeData(color: lightText),
    cardTheme: CardThemeData(
      color: lightSurface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightPrimary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: darkPrimary,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: darkPrimary,
      secondary: darkSecondary,
      surface: darkSurface,
      background: darkBackground,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkSurface,
      foregroundColor: darkText,
      elevation: 0,
      iconTheme: IconThemeData(color: darkText),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: darkText, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: darkText, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(color: darkText, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: darkText, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(color: darkText, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: darkText, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: darkText),
      bodyMedium: TextStyle(color: darkTextSecondary),
    ),
    iconTheme: const IconThemeData(color: darkText),
    cardTheme: CardThemeData(
      color: darkSurface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkPrimary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
    ),
  );
}
