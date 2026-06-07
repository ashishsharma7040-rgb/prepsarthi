// lib/core/theme/app_theme.dart
//
// Shanti Scholar theme — PrepSarthi
//
// Font change:  Poppins  → Nunito  (headings — warmer, rounded, inviting)
//               Inter    → DM Sans (body — exceptional small-size readability)
// Color change: all via app_colors.dart — no hardcoded hex here.
// API:          AppTheme.lightTheme() / AppTheme.darkTheme() — unchanged.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  // ─── Text Theme ────────────────────────────────────────────────────────────
  // Nunito   → display / headline / title  — warm, rounded, inviting
  // DM Sans  → body / label / caption      — clean, study-friendly at small sizes
  // Both fonts support Devanagari fallback gracefully through google_fonts.
  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    return TextTheme(
      // ── Display ─────────────────────────────────────────────────────────
      displayLarge: GoogleFonts.nunito(
        fontSize: 36, fontWeight: FontWeight.w800,
        color: primary, height: 1.12, letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.nunito(
        fontSize: 28, fontWeight: FontWeight.w700,
        color: primary, height: 1.16, letterSpacing: -0.3,
      ),
      displaySmall: GoogleFonts.nunito(
        fontSize: 22, fontWeight: FontWeight.w700,
        color: primary, height: 1.2, letterSpacing: -0.2,
      ),
      // ── Headline ────────────────────────────────────────────────────────
      headlineLarge: GoogleFonts.nunito(
        fontSize: 20, fontWeight: FontWeight.w700, color: primary,
      ),
      headlineMedium: GoogleFonts.nunito(
        fontSize: 18, fontWeight: FontWeight.w700, color: primary,
      ),
      headlineSmall: GoogleFonts.nunito(
        fontSize: 16, fontWeight: FontWeight.w600, color: primary,
      ),
      // ── Title ────────────────────────────────────────────────────────────
      titleLarge: GoogleFonts.nunito(
        fontSize: 15, fontWeight: FontWeight.w600, color: primary,
      ),
      titleMedium: GoogleFonts.dmSans(
        fontSize: 14, fontWeight: FontWeight.w500, color: primary,
        letterSpacing: 0.1,
      ),
      titleSmall: GoogleFonts.dmSans(
        fontSize: 13, fontWeight: FontWeight.w500, color: secondary,
        letterSpacing: 0.1,
      ),
      // ── Body — optimised for long-form reading ───────────────────────────
      bodyLarge: GoogleFonts.dmSans(
        fontSize: 15, fontWeight: FontWeight.w400, color: primary,
        height: 1.6,  // generous line height — reduces fatigue in long sessions
      ),
      bodyMedium: GoogleFonts.dmSans(
        fontSize: 14, fontWeight: FontWeight.w400, color: primary, height: 1.55,
      ),
      bodySmall: GoogleFonts.dmSans(
        fontSize: 12, fontWeight: FontWeight.w400, color: secondary, height: 1.5,
      ),
      // ── Label ────────────────────────────────────────────────────────────
      labelLarge: GoogleFonts.dmSans(
        fontSize: 14, fontWeight: FontWeight.w600, color: primary,
        letterSpacing: 0.2,
      ),
      labelMedium: GoogleFonts.dmSans(
        fontSize: 12, fontWeight: FontWeight.w500, color: secondary,
        letterSpacing: 0.3,
      ),
      labelSmall: GoogleFonts.dmSans(
        fontSize: 11, fontWeight: FontWeight.w500, color: secondary,
        letterSpacing: 0.4,
      ),
    );
  }

  // ─── Light Theme ───────────────────────────────────────────────────────────
  static ThemeData lightTheme() {
    const cs = ColorScheme(
      brightness: Brightness.light,
      primary: LightColors.primary,
      onPrimary: LightColors.onPrimary,
      primaryContainer: LightColors.primaryContainer,
      onPrimaryContainer: Color(0xFF0F2E20),
      secondary: LightColors.secondary,
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: LightColors.secondaryContainer,
      onSecondaryContainer: Color(0xFF3A1800),
      tertiary: LightColors.tertiary,
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: LightColors.tertiaryContainer,
      onTertiaryContainer: Color(0xFF1A1D4A),
      error: LightColors.error,
      onError: Colors.white,
      errorContainer: Color(0xFFF9DDE0),
      onErrorContainer: Color(0xFF4A0E15),
      surface: LightColors.surface,
      onSurface: LightColors.onSurface,
      surfaceContainerHighest: LightColors.surfaceVariant,
      onSurfaceVariant: LightColors.onSurfaceVariant,
      outline: LightColors.outline,
      outlineVariant: LightColors.outlineVariant,
      shadow: LightColors.shadow,
      scrim: Colors.black54,
      inverseSurface: Color(0xFF2A302C),
      onInverseSurface: Color(0xFFF5F3EE),
      inversePrimary: Color(0xFF9DBDAA),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: LightColors.background,
      textTheme: _buildTextTheme(LightColors.onSurface, LightColors.onSurfaceVariant),

      // ── AppBar ────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 18, fontWeight: FontWeight.w700,
          color: LightColors.onSurface,
        ),
        iconTheme: const IconThemeData(color: LightColors.onSurface, size: 22),
        actionsIconTheme: const IconThemeData(color: LightColors.onSurfaceVariant, size: 22),
      ),

      // ── Card ──────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: LightColors.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(18)),
          side: BorderSide(color: LightColors.outline.withOpacity(0.6), width: 0.8),
        ),
        shadowColor: LightColors.shadow,
        margin: EdgeInsets.zero,
      ),

      // ── Filled Button ──────────────────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: LightColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          elevation: 0,
          textStyle: GoogleFonts.nunito(
            fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.2,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),

      // ── Outlined Button ────────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: LightColors.primary,
          side: const BorderSide(color: LightColors.primary, width: 1.5),
          minimumSize: const Size(double.infinity, 52),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 15, fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),

      // ── Text Button ────────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: LightColors.primary,
          textStyle: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
      ),

      // ── Input Decoration ───────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LightColors.surfaceVariant,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: LightColors.outline.withOpacity(0.7), width: 0.8),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: LightColors.primary, width: 1.8),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: LightColors.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: GoogleFonts.dmSans(color: LightColors.onSurfaceVariant, fontSize: 14),
        hintStyle: GoogleFonts.dmSans(
          color: LightColors.onSurfaceVariant.withOpacity(0.7), fontSize: 14,
        ),
        floatingLabelStyle: GoogleFonts.dmSans(
          color: LightColors.primary, fontSize: 13, fontWeight: FontWeight.w500,
        ),
      ),

      // ── Chip ──────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: LightColors.surfaceVariant,
        selectedColor: LightColors.primaryContainer,
        labelStyle: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        side: BorderSide(color: LightColors.outline.withOpacity(0.5), width: 0.8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      // ── Bottom Navigation ──────────────────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: LightColors.surface,
        selectedItemColor: LightColors.primary,
        unselectedItemColor: LightColors.onSurfaceVariant,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: LightColors.surface,
        indicatorColor: LightColors.primaryContainer,
        elevation: 0,
      ),

      // ── Divider ───────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: LightColors.outline.withOpacity(0.5), thickness: 0.8, space: 0,
      ),

      // ── Progress Indicator ─────────────────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: LightColors.primary,
        linearTrackColor: LightColors.primaryContainer,
        circularTrackColor: LightColors.primaryContainer,
        linearMinHeight: 6,
      ),

      // ── Snack Bar ──────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        backgroundColor: LightColors.onSurface,
        contentTextStyle: GoogleFonts.dmSans(
          color: LightColors.background, fontSize: 14, height: 1.4,
        ),
        elevation: 4,
      ),

      // ── Dialog ────────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: LightColors.surface,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 18, fontWeight: FontWeight.w700, color: LightColors.onSurface,
        ),
        contentTextStyle: GoogleFonts.dmSans(
          fontSize: 14, color: LightColors.onSurfaceVariant, height: 1.5,
        ),
      ),

      // ── Bottom Sheet ───────────────────────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: LightColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        showDragHandle: true,
        dragHandleColor: LightColors.outline,
      ),

      // ── List Tile ─────────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        tileColor: Colors.transparent,
        titleTextStyle: GoogleFonts.dmSans(
          fontSize: 15, fontWeight: FontWeight.w500, color: LightColors.onSurface,
        ),
        subtitleTextStyle: GoogleFonts.dmSans(
          fontSize: 13, color: LightColors.onSurfaceVariant,
        ),
      ),

      // ── Switch ────────────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return LightColors.primary;
          return LightColors.onSurfaceVariant.withOpacity(0.5);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return LightColors.primaryContainer;
          return LightColors.surfaceVariant;
        }),
      ),

      // ── Slider ────────────────────────────────────────────────────────────
      sliderTheme: SliderThemeData(
        activeTrackColor: LightColors.primary,
        inactiveTrackColor: LightColors.primaryContainer,
        thumbColor: LightColors.primary,
        overlayColor: LightColors.primary.withOpacity(0.12),
        trackHeight: 4,
      ),

      // ── Tooltip ───────────────────────────────────────────────────────────
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: LightColors.onSurface.withOpacity(0.88),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        textStyle: GoogleFonts.dmSans(fontSize: 12, color: LightColors.background),
      ),
    );
  }

  // ─── Dark Theme ────────────────────────────────────────────────────────────
  static ThemeData darkTheme() {
    const cs = ColorScheme(
      brightness: Brightness.dark,
      primary: DarkColors.primary,
      onPrimary: DarkColors.onPrimary,
      primaryContainer: DarkColors.primaryContainer,
      onPrimaryContainer: DarkColors.onSurface,
      secondary: DarkColors.secondary,
      onSecondary: Color(0xFF1A0A00),
      secondaryContainer: DarkColors.secondaryContainer,
      onSecondaryContainer: Color(0xFFF5C9A8),
      tertiary: DarkColors.tertiary,
      onTertiary: Color(0xFF0F1030),
      tertiaryContainer: DarkColors.tertiaryContainer,
      onTertiaryContainer: Color(0xFFC5C7E8),
      error: DarkColors.error,
      onError: Color(0xFF1A0009),
      errorContainer: Color(0xFF5C1A20),
      onErrorContainer: Color(0xFFF9DDE0),
      surface: DarkColors.surface,
      onSurface: DarkColors.onSurface,
      surfaceContainerHighest: DarkColors.surfaceVariant,
      onSurfaceVariant: DarkColors.onSurfaceVariant,
      outline: DarkColors.outline,
      outlineVariant: DarkColors.outlineVariant,
      shadow: Colors.black,
      scrim: Colors.black87,
      inverseSurface: Color(0xFFEDE9E1),
      onInverseSurface: Color(0xFF181C1F),
      inversePrimary: Color(0xFF5C7A6B),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: DarkColors.background,
      textTheme: _buildTextTheme(DarkColors.onSurface, DarkColors.onSurfaceVariant),

      // ── AppBar ────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 18, fontWeight: FontWeight.w700,
          color: DarkColors.onSurface,
        ),
        iconTheme: const IconThemeData(color: DarkColors.onSurface, size: 22),
        actionsIconTheme: const IconThemeData(color: DarkColors.onSurfaceVariant, size: 22),
      ),

      // ── Card ──────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: DarkColors.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(18)),
          side: BorderSide(color: DarkColors.outline.withOpacity(0.8), width: 0.8),
        ),
        shadowColor: Colors.black54,
        margin: EdgeInsets.zero,
      ),

      // ── Filled Button ──────────────────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: DarkColors.primary,
          foregroundColor: DarkColors.onPrimary,
          minimumSize: const Size(double.infinity, 52),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          elevation: 0,
          textStyle: GoogleFonts.nunito(
            fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.2,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),

      // ── Outlined Button ────────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DarkColors.primary,
          side: const BorderSide(color: DarkColors.primary, width: 1.5),
          minimumSize: const Size(double.infinity, 52),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 15, fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),

      // ── Text Button ────────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: DarkColors.primary,
          textStyle: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
      ),

      // ── Input Decoration ───────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DarkColors.surfaceVariant,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: DarkColors.outline.withOpacity(0.8), width: 0.8),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: DarkColors.primary, width: 1.8),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: DarkColors.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: GoogleFonts.dmSans(color: DarkColors.onSurfaceVariant, fontSize: 14),
        hintStyle: GoogleFonts.dmSans(
          color: DarkColors.onSurfaceVariant.withOpacity(0.6), fontSize: 14,
        ),
        floatingLabelStyle: GoogleFonts.dmSans(
          color: DarkColors.primary, fontSize: 13, fontWeight: FontWeight.w500,
        ),
      ),

      // ── Chip ──────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: DarkColors.surfaceVariant,
        selectedColor: DarkColors.primaryContainer,
        labelStyle: GoogleFonts.dmSans(
          fontSize: 13, fontWeight: FontWeight.w500, color: DarkColors.onSurface,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        side: BorderSide(color: DarkColors.outline.withOpacity(0.7), width: 0.8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      // ── Bottom Navigation ──────────────────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: DarkColors.surface,
        selectedItemColor: DarkColors.primary,
        unselectedItemColor: DarkColors.onSurfaceVariant,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: DarkColors.surface,
        indicatorColor: DarkColors.primaryContainer,
        elevation: 0,
      ),

      // ── Divider ───────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: DarkColors.outline.withOpacity(0.6), thickness: 0.8, space: 0,
      ),

      // ── Progress Indicator ─────────────────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: DarkColors.primary,
        linearTrackColor: DarkColors.primaryContainer,
        circularTrackColor: DarkColors.primaryContainer,
        linearMinHeight: 6,
      ),

      // ── Snack Bar ──────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        backgroundColor: DarkColors.surfaceVariant,
        contentTextStyle: GoogleFonts.dmSans(
          color: DarkColors.onSurface, fontSize: 14, height: 1.4,
        ),
        elevation: 4,
      ),

      // ── Dialog ────────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: DarkColors.surfaceCard,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 18, fontWeight: FontWeight.w700, color: DarkColors.onSurface,
        ),
        contentTextStyle: GoogleFonts.dmSans(
          fontSize: 14, color: DarkColors.onSurfaceVariant, height: 1.5,
        ),
      ),

      // ── Bottom Sheet ───────────────────────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: DarkColors.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        showDragHandle: true,
        dragHandleColor: DarkColors.outline,
      ),

      // ── List Tile ─────────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        tileColor: Colors.transparent,
        titleTextStyle: GoogleFonts.dmSans(
          fontSize: 15, fontWeight: FontWeight.w500, color: DarkColors.onSurface,
        ),
        subtitleTextStyle: GoogleFonts.dmSans(
          fontSize: 13, color: DarkColors.onSurfaceVariant,
        ),
      ),

      // ── Switch ────────────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return DarkColors.primary;
          return DarkColors.onSurfaceVariant.withOpacity(0.5);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return DarkColors.primaryContainer;
          return DarkColors.surfaceVariant;
        }),
      ),

      // ── Slider ────────────────────────────────────────────────────────────
      sliderTheme: SliderThemeData(
        activeTrackColor: DarkColors.primary,
        inactiveTrackColor: DarkColors.primaryContainer,
        thumbColor: DarkColors.primary,
        overlayColor: DarkColors.primary.withOpacity(0.16),
        trackHeight: 4,
      ),

      // ── Tooltip ───────────────────────────────────────────────────────────
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: DarkColors.surfaceVariant,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          border: Border.all(color: DarkColors.outline),
        ),
        textStyle: GoogleFonts.dmSans(fontSize: 12, color: DarkColors.onSurface),
      ),
    );
  }
}
