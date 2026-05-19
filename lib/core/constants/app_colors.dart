// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

// ─── Light Theme: Positive Vibe ───────────────────────────────────────────────
class LightColors {
  static const primary = Color(0xFF00C4B4);       // teal
  static const primaryDark = Color(0xFF009688);
  static const secondary = Color(0xFFFFD700);      // gold
  static const tertiary = Color(0xFF4CAF50);       // green
  static const background = Color(0xFFFFFFFF);
  static const surface = Color(0xFFF8F9FA);
  static const surfaceVariant = Color(0xFFEDF2F7);
  static const error = Color(0xFFE53935);
  static const onPrimary = Color(0xFFFFFFFF);
  static const onSurface = Color(0xFF1A202C);
  static const onSurfaceVariant = Color(0xFF4A5568);
  static const outline = Color(0xFFCBD5E0);
  static const shadow = Color(0x1A000000);

  // Subject Colors
  static const physics = Color(0xFF6C63FF);
  static const chemistry = Color(0xFFFF6B6B);
  static const mathematics = Color(0xFF00C4B4);
  static const biology = Color(0xFF4CAF50);

  // Status Colors
  static const learned = Color(0xFF4CAF50);
  static const revised = Color(0xFF2196F3);
  static const tested = Color(0xFFFF9800);
  static const pyqDone = Color(0xFF9C27B0);
  static const notesMade = Color(0xFF00BCD4);

  // Gradient Pairs
  static const gradientPrimary = [Color(0xFF00C4B4), Color(0xFF4CAF50)];
  static const gradientGold = [Color(0xFFFFD700), Color(0xFFFF8C00)];
  static const gradientPhysics = [Color(0xFF6C63FF), Color(0xFF9C88FF)];
  static const gradientChemistry = [Color(0xFFFF6B6B), Color(0xFFFF8E53)];
  static const gradientMath = [Color(0xFF00C4B4), Color(0xFF00BFFF)];
  static const gradientBiology = [Color(0xFF4CAF50), Color(0xFF8BC34A)];
}

// ─── Dark Theme: Night Sky ────────────────────────────────────────────────────
class DarkColors {
  static const primary = Color(0xFF7B68EE);        // medium slate blue
  static const primaryDark = Color(0xFF6A5ACD);
  static const secondary = Color(0xFF00BFFF);      // deep sky blue / glow
  static const tertiary = Color(0xFF48BB78);
  static const background = Color(0xFF0A192F);     // deep navy
  static const surface = Color(0xFF1E2A3A);
  static const surfaceVariant = Color(0xFF172A45);
  static const surfaceCard = Color(0xFF1A2744);
  static const error = Color(0xFFEF5350);
  static const onPrimary = Color(0xFFFFFFFF);
  static const onSurface = Color(0xFFE2E8F0);
  static const onSurfaceVariant = Color(0xFF94A3B8);
  static const outline = Color(0xFF2D4A6A);
  static const glow = Color(0x337B68EE);
  static const starColor = Color(0x66FFFFFF);

  // Subject Colors (brighter for dark bg)
  static const physics = Color(0xFF9C88FF);
  static const chemistry = Color(0xFFFF7675);
  static const mathematics = Color(0xFF00BFFF);
  static const biology = Color(0xFF55EFC4);

  // Gradient Pairs
  static const gradientPrimary = [Color(0xFF7B68EE), Color(0xFF00BFFF)];
  static const gradientCard = [Color(0xFF1E2A3A), Color(0xFF172A45)];
  static const gradientPhysics = [Color(0xFF6C63FF), Color(0xFF4C63D2)];
  static const gradientChemistry = [Color(0xFFFF6B6B), Color(0xFFD63031)];
}

// ─── Shared semantic colors ───────────────────────────────────────────────────
class AppColors {
  // Difficulty Colors
  static const diffEasy = Color(0xFF4CAF50);
  static const diffMedium = Color(0xFFFF9800);
  static const diffHard = Color(0xFFF44336);

  // Weightage heat
  static const weightHigh = Color(0xFFFF5252);
  static const weightMed = Color(0xFFFFAB40);
  static const weightLow = Color(0xFF69F0AE);

  // Heatmap
  static const heatEmpty = Color(0xFFEDF2F7);
  static const heat1 = Color(0xFF9BE9A8);
  static const heat2 = Color(0xFF40C463);
  static const heat3 = Color(0xFF30A14E);
  static const heat4 = Color(0xFF216E39);

  static const heatEmptyDark = Color(0xFF161B22);
  static const heat1Dark = Color(0xFF0E4429);
  static const heat2Dark = Color(0xFF006D32);
  static const heat3Dark = Color(0xFF26A641);
  static const heat4Dark = Color(0xFF39D353);
}
