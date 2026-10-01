import 'package:flutter/material.dart';

class AppTheme {
  // A restrained fintech color system
  static const Color primaryAccent = Color(0xFF4F46E5); // Tailwind indigo-600
  static const Color secondaryAccent = Color(0xFF0EA5E9); // Tailwind sky-500

  static const Color success = Color(0xFF10B981); // Tailwind emerald-500
  static const Color danger = Color(0xFFEF4444); // Tailwind red-500
  static const Color warning = Color(0xFFF59E0B); // Tailwind amber-500
  static const Color info = Color(0xFF3B82F6); // Tailwind blue-500

  static const Color background = Color(0xFFF9FAFB); // Tailwind gray-50
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFE5E7EB); // Tailwind gray-200

  static const Color textPrimary = Color(0xFF111827); // Tailwind gray-900
  static const Color textSecondary = Color(0xFF6B7280); // Tailwind gray-500

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primaryAccent,
        onPrimary: Colors.white,
        secondary: secondaryAccent,
        onSecondary: Colors.white,
        surface: surface,
        onSurface: textPrimary,
        error: danger,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: background,
      fontFamily: 'Vazirmatn', // New typography
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: 'Vazirmatn',
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0, // Flat design with border instead
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryAccent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Vazirmatn',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryAccent,
          textStyle: const TextStyle(
            fontFamily: 'Vazirmatn',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryAccent,
          side: const BorderSide(color: border, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Vazirmatn',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryAccent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: danger, width: 1),
        ),
        labelStyle: const TextStyle(
          color: textSecondary,
          fontFamily: 'Vazirmatn',
        ),
        hintStyle: const TextStyle(
          color: Color(0xFF9CA3AF),
          fontFamily: 'Vazirmatn',
        ), // Tailwind gray-400
      ),
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primaryAccent,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontFamily: 'Vazirmatn', color: textPrimary),
        bodyMedium: TextStyle(fontFamily: 'Vazirmatn', color: textPrimary),
        bodySmall: TextStyle(fontFamily: 'Vazirmatn', color: textSecondary),
        titleLarge: TextStyle(
          fontFamily: 'Vazirmatn',
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Vazirmatn',
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(
          fontFamily: 'Vazirmatn',
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
        labelLarge: TextStyle(
          fontFamily: 'Vazirmatn',
          color: textPrimary,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: TextStyle(
          fontFamily: 'Vazirmatn',
          color: textSecondary,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          fontFamily: 'Vazirmatn',
          color: textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Fallbacks for backward compatibility while refactoring
  static Color get error => danger;
  static Color get borderColor => border;
}
