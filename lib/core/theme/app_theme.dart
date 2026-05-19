// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  // ─── Text Styles ──────────────────────────────────────────────────────────
  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 36, fontWeight: FontWeight.w700, color: primary, height: 1.15,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 28, fontWeight: FontWeight.w700, color: primary, height: 1.2,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 22, fontWeight: FontWeight.w600, color: primary, height: 1.25,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 20, fontWeight: FontWeight.w600, color: primary,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 18, fontWeight: FontWeight.w600, color: primary,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 16, fontWeight: FontWeight.w600, color: primary,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 15, fontWeight: FontWeight.w600, color: primary,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w500, color: primary,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 13, fontWeight: FontWeight.w500, color: secondary,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 15, fontWeight: FontWeight.w400, color: primary, height: 1.5,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w400, color: primary, height: 1.5,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w400, color: secondary, height: 1.4,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w600, color: primary,
        letterSpacing: 0.3,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w500, color: secondary,
        letterSpacing: 0.4,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11, fontWeight: FontWeight.w500, color: secondary,
        letterSpacing: 0.5,
      ),
    );
  }

  // ─── Light Theme ─────────────────────────────────────────────────────────
  static ThemeData lightTheme() {
    const cs = ColorScheme(
      brightness: Brightness.light,
      primary: LightColors.primary,
      onPrimary: LightColors.onPrimary,
      primaryContainer: Color(0xFFB2DFDB),
      onPrimaryContainer: Color(0xFF004D45),
      secondary: LightColors.secondary,
      onSecondary: Color(0xFF1A1A1A),
      secondaryContainer: Color(0xFFFFF9C4),
      onSecondaryContainer: Color(0xFF33280A),
      tertiary: LightColors.tertiary,
      onTertiary: LightColors.onPrimary,
      tertiaryContainer: Color(0xFFC8E6C9),
      onTertiaryContainer: Color(0xFF1B5E20),
      error: LightColors.error,
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF93000A),
      background: LightColors.background,
      onBackground: LightColors.onSurface,
      surface: LightColors.surface,
      onSurface: LightColors.onSurface,
      surfaceVariant: LightColors.surfaceVariant,
      onSurfaceVariant: LightColors.onSurfaceVariant,
      outline: LightColors.outline,
      outlineVariant: Color(0xFFE2E8F0),
      shadow: LightColors.shadow,
      scrim: Colors.black54,
      inverseSurface: Color(0xFF2D3748),
      onInverseSurface: Colors.white,
      inversePrimary: Color(0xFF80CBC4),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      textTheme: _buildTextTheme(LightColors.onSurface, LightColors.onSurfaceVariant),
      scaffoldBackgroundColor: LightColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
        ),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18, fontWeight: FontWeight.w600,
          color: LightColors.onSurface,
        ),
        iconTheme: const IconThemeData(color: LightColors.onSurface),
      ),
      cardTheme: const CardThemeData(
        color: LightColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: LightColors.outline, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: LightColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: LightColors.primary,
          side: const BorderSide(color: LightColors.primary, width: 1.5),
          minimumSize: const Size(double.infinity, 52),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LightColors.surfaceVariant,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: LightColors.outline, width: 0.5),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: LightColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: GoogleFonts.inter(color: LightColors.onSurfaceVariant),
        hintStyle: GoogleFonts.inter(color: LightColors.onSurfaceVariant),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: LightColors.surfaceVariant,
        selectedColor: LightColors.primary.withOpacity(0.15),
        labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        side: const BorderSide(color: LightColors.outline, width: 0.5),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: LightColors.surface,
        selectedItemColor: LightColors.primary,
        unselectedItemColor: LightColors.onSurfaceVariant,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      dividerTheme: const DividerThemeData(
        color: LightColors.outline, thickness: 0.5,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        backgroundColor: LightColors.onSurface,
        contentTextStyle: GoogleFonts.inter(color: Colors.white, fontSize: 14),
      ),
    );
  }

  // ─── Dark Theme ───────────────────────────────────────────────────────────
  static ThemeData darkTheme() {
    const cs = ColorScheme(
      brightness: Brightness.dark,
      primary: DarkColors.primary,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFF3D3070),
      onPrimaryContainer: Color(0xFFD4CEFF),
      secondary: DarkColors.secondary,
      onSecondary: Color(0xFF003F5C),
      secondaryContainer: Color(0xFF004B70),
      onSecondaryContainer: Color(0xFF9BE8FF),
      tertiary: DarkColors.tertiary,
      onTertiary: Colors.black,
      tertiaryContainer: Color(0xFF1B4332),
      onTertiaryContainer: Color(0xFFB7E4C7),
      error: DarkColors.error,
      onError: Colors.white,
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      background: DarkColors.background,
      onBackground: DarkColors.onSurface,
      surface: DarkColors.surface,
      onSurface: DarkColors.onSurface,
      surfaceVariant: DarkColors.surfaceVariant,
      onSurfaceVariant: DarkColors.onSurfaceVariant,
      outline: DarkColors.outline,
      outlineVariant: Color(0xFF1E3A5F),
      shadow: Colors.black,
      scrim: Colors.black87,
      inverseSurface: Color(0xFFE2E8F0),
      onInverseSurface: DarkColors.background,
      inversePrimary: Color(0xFF4A3F9E),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      textTheme: _buildTextTheme(DarkColors.onSurface, DarkColors.onSurfaceVariant),
      scaffoldBackgroundColor: DarkColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
        ),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18, fontWeight: FontWeight.w600,
          color: DarkColors.onSurface,
        ),
        iconTheme: const IconThemeData(color: DarkColors.onSurface),
      ),
      cardTheme: const CardThemeData(
        color: DarkColors.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: DarkColors.outline, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: DarkColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DarkColors.primary,
          side: const BorderSide(color: DarkColors.primary, width: 1.5),
          minimumSize: const Size(double.infinity, 52),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DarkColors.surfaceVariant,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: DarkColors.outline, width: 0.5),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: DarkColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: GoogleFonts.inter(color: DarkColors.onSurfaceVariant),
        hintStyle: GoogleFonts.inter(color: DarkColors.onSurfaceVariant),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: DarkColors.surfaceVariant,
        selectedColor: DarkColors.primary.withOpacity(0.25),
        labelStyle: GoogleFonts.inter(
          fontSize: 13, fontWeight: FontWeight.w500, color: DarkColors.onSurface,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        side: const BorderSide(color: DarkColors.outline, width: 0.5),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: DarkColors.surface,
        selectedItemColor: DarkColors.primary,
        unselectedItemColor: DarkColors.onSurfaceVariant,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      dividerTheme: const DividerThemeData(
        color: DarkColors.outline, thickness: 0.5,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        backgroundColor: DarkColors.surfaceVariant,
        contentTextStyle: GoogleFonts.inter(color: DarkColors.onSurface, fontSize: 14),
      ),
    );
  }
}
