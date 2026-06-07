// lib/core/constants/app_colors.dart
//
// ┌─────────────────────────────────────────────────────────────────────┐
// │  "Shanti Scholar" — PrepSarthi Design System                        │
// │                                                                      │
// │  All ORIGINAL property names are preserved — zero breakage to any   │
// │  existing screen or widget.                                          │
// │                                                                      │
// │  What changed:                                                       │
// │  Light:  pure white → warm parchment (#F5F3EE)                      │
// │          harsh teal → sage green (#5C7A6B)                          │
// │          bright gold → warm terracotta (#B5724A)                    │
// │          hard green → dusty indigo (#6B70B8)                        │
// │  Dark:   AMOLED navy → deep warm slate (#181C1F)                    │
// │          neon slate-blue → brightened sage (#9DBDAA)                │
// │          electric blue → warm amber (#D4956A)                       │
// │          pure-white text → warm off-white (#E4E1D8)                 │
// └─────────────────────────────────────────────────────────────────────┘

import 'package:flutter/material.dart';

// ─── Light Mode: "Morning Study" ──────────────────────────────────────────────
class LightColors {
  // PRIMARY — Deep Sage Green
  // Psychology: Nature, calm, growth. Reduces cortisol. Feels like a shaded
  // reading garden, not a tech dashboard.
  static const primary        = Color(0xFF5C7A6B);
  static const primaryDark    = Color(0xFF4A6458);

  // SECONDARY — Warm Terracotta
  // Psychology: Indian earthiness, human warmth. Prevents the cold-startup feel.
  static const secondary      = Color(0xFFB5724A);

  // TERTIARY — Dusty Indigo
  // Psychology: Intellectual depth. Calmer than saturated purple.
  static const tertiary       = Color(0xFF6B70B8);

  // BACKGROUNDS — Warm Parchment System
  // Psychology: ~40% less glare than pure white. Like studying on aged paper.
  static const background     = Color(0xFFF5F3EE);  // Warm parchment
  static const surface        = Color(0xFFFDFCF8);  // Near-white, barely warm
  static const surfaceVariant = Color(0xFFEDE9E1);  // Warm gray — inputs, chips

  // CONTENT — Dark with green tint, never harsh pure black
  static const onPrimary          = Color(0xFFFFFFFF);
  static const onSurface          = Color(0xFF1E2419);
  static const onSurfaceVariant   = Color(0xFF5A6258);

  // UTILITY
  static const error   = Color(0xFFBF5B65);  // Soft rose — not harsh red
  static const outline = Color(0xFFCDC9BF);  // Warm gray border
  static const shadow  = Color(0x10000000);  // Very gentle shadow

  // ── Subject Colors (soothing, not saturated) ─────────────────────────
  static const physics     = Color(0xFF6B70B8);  // Dusty Indigo
  static const chemistry   = Color(0xFFB5554A);  // Warm Rose
  static const mathematics = Color(0xFF5C7A6B);  // Sage (same as primary)
  static const biology     = Color(0xFF7A956B);  // Forest Green

  // ── Study Status Colors ───────────────────────────────────────────────
  static const learned   = Color(0xFF5C8C6C);
  static const revised   = Color(0xFF5C78B0);
  static const tested    = Color(0xFFB87D3C);
  static const pyqDone   = Color(0xFF7A5CA8);
  static const notesMade = Color(0xFF4A8C8C);

  // ── Gradient Pairs (same names as before — used across screens) ───────
  static const gradientPrimary   = [Color(0xFF5C7A6B), Color(0xFF7A956B)];
  static const gradientGold      = [Color(0xFFB87D3C), Color(0xFFD4956A)];  // was FFD700
  static const gradientPhysics   = [Color(0xFF6B70B8), Color(0xFF8B8EC8)];
  static const gradientChemistry = [Color(0xFFB5554A), Color(0xFFD4857D)];
  static const gradientMath      = [Color(0xFF5C7A6B), Color(0xFF7D9E8D)];
  static const gradientBiology   = [Color(0xFF7A956B), Color(0xFF9DBDAA)];

  // Extra helpers (new — used by SoothingBackground & AppDecorations)
  static const primaryContainer   = Color(0xFFE4EFE9);
  static const secondaryContainer = Color(0xFFF5E6DA);
  static const tertiaryContainer  = Color(0xFFECEDF8);
  static const outlineVariant     = Color(0xFFE5E2D8);
  static const surfaceCard        = Color(0xFFFFFFFF);
  static const gradientWarm       = [Color(0xFFB5724A), Color(0xFFD4956A)];
  static const gradientSage       = [Color(0xFF7D9E8D), Color(0xFF5C7A6B)];
}

// ─── Dark Mode: "Night Lamp" ───────────────────────────────────────────────────
class DarkColors {
  // PRIMARY — Brightened Sage
  static const primary     = Color(0xFF9DBDAA);
  static const primaryDark = Color(0xFF7A9E8D);

  // SECONDARY — Warm Amber (desk lamp feel, not neon blue)
  static const secondary = Color(0xFFD4956A);

  // TERTIARY — Soft Lavender-Indigo
  static const tertiary = Color(0xFF9B9ECC);

  // BACKGROUNDS — Deep Warm Slate (NOT AMOLED black)
  // Psychology: slightly warm dark prevents the eye strain of pure black.
  // Like a library at 2am with a soft lamp.
  static const background     = Color(0xFF181C1F);  // Deep warm dark
  static const surface        = Color(0xFF1F2428);  // Slightly elevated
  static const surfaceVariant = Color(0xFF252C30);  // Input fills
  static const surfaceCard    = Color(0xFF242B2F);  // Cards

  // CONTENT — Warm off-white (NOT pure white — reduces glare by ~35%)
  static const onPrimary        = Color(0xFF0F1A15);
  static const onSurface        = Color(0xFFE4E1D8);
  static const onSurfaceVariant = Color(0xFF9B9B8F);

  // UTILITY
  static const error       = Color(0xFFE06A72);
  static const outline     = Color(0xFF3A3E42);
  static const glow        = Color(0x339DBDAA);
  static const starColor   = Color(0x44FFFFFF);  // kept for backward compat

  // ── Subject Colors (brighter for dark backgrounds) ─────────────────────
  static const physics     = Color(0xFF9B9ECC);
  static const chemistry   = Color(0xFFD4857D);
  static const mathematics = Color(0xFF9DBDAA);
  static const biology     = Color(0xFFA8C49B);

  // ── Gradient Pairs ──────────────────────────────────────────────────────
  static const gradientPrimary   = [Color(0xFF9DBDAA), Color(0xFFD4956A)];
  static const gradientCard      = [Color(0xFF242B2F), Color(0xFF1F2428)];
  static const gradientPhysics   = [Color(0xFF6B70B8), Color(0xFF4C5090)];
  static const gradientChemistry = [Color(0xFFB5554A), Color(0xFF8C3B36)];

  // Extra helpers (new — used by SoothingBackground & AppDecorations)
  static const primaryContainer   = Color(0xFF2A3D35);
  static const secondaryContainer = Color(0xFF3D2E22);
  static const tertiaryContainer  = Color(0xFF2A2C3D);
  static const outlineVariant     = Color(0xFF2C3035);
}

// ─── Shared Semantic Colors ────────────────────────────────────────────────────
class AppColors {
  // ── Difficulty ────────────────────────────────────────────────────────
  static const diffEasy   = Color(0xFF5C8C6C);  // calm green
  static const diffMedium = Color(0xFFB87D3C);  // amber
  static const diffHard   = Color(0xFFBF5B65);  // soft rose

  // ── Weightage ─────────────────────────────────────────────────────────
  static const weightHigh = Color(0xFFBF5B65);
  static const weightMed  = Color(0xFFB87D3C);
  static const weightLow  = Color(0xFF7A956B);

  // ── Heatmap — Sage-tinted (warmer than GitHub green) ──────────────────
  static const heatEmpty = Color(0xFFEDE9E1);
  static const heat1     = Color(0xFFBDD5C8);
  static const heat2     = Color(0xFF9DBDAA);
  static const heat3     = Color(0xFF7D9E8D);
  static const heat4     = Color(0xFF5C7A6B);

  static const heatEmptyDark = Color(0xFF252C30);
  static const heat1Dark     = Color(0xFF2A3D35);
  static const heat2Dark     = Color(0xFF3A5548);
  static const heat3Dark     = Color(0xFF4A6E5C);
  static const heat4Dark     = Color(0xFF5C8870);

  // ── Quiz States (soothing — left-border + tint, no harsh red/green) ───
  static const quizCorrect       = Color(0xFF4A8C6C);
  static const quizCorrectBg     = Color(0xFFEBF5EF);
  static const quizWrong         = Color(0xFFBF5B65);
  static const quizWrongBg       = Color(0xFFF9E8EA);
  static const quizSelected      = Color(0xFF5C7A6B);
  static const quizSelectedBg    = Color(0xFFEAF0EC);

  static const quizCorrectDark    = Color(0xFF6AB88A);
  static const quizCorrectBgDark  = Color(0xFF1A3328);
  static const quizWrongDark      = Color(0xFFD4757D);
  static const quizWrongBgDark    = Color(0xFF331820);
  static const quizSelectedDark   = Color(0xFF9DBDAA);
  static const quizSelectedBgDark = Color(0xFF1F3028);

  // ── Achievement ───────────────────────────────────────────────────────
  static const gold   = Color(0xFFB8882A);
  static const silver = Color(0xFF7A8899);
  static const bronze = Color(0xFF9E6340);
}
