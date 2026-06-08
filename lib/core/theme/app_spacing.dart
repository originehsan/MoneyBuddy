// MoneyBuddy
import 'package:flutter/material.dart';

/// MoneyBuddy — Spacing System (4px base grid)
/// Usage: Padding(padding: EdgeInsets.all(AppSpacing.md))
class AppSpacing {
  AppSpacing._();

  static const double xs    = 4;
  static const double sm    = 8;
  static const double md    = 12;
  static const double lg    = 16;
  static const double xl    = 20;
  static const double xxl   = 24;
  static const double xxxl  = 32;
  static const double huge  = 40;
  static const double giant = 48;

  // ── Semantic aliases ───────────────────────────────────────────
  static const double screenH      = xxl;
  static const double screenV      = xl;
  static const double cardPadding  = lg;
  static const double sectionGap   = xxl;
  static const double fieldGap     = lg;
  static const double tileV        = md;
  static const double tileH        = lg;
  static const double iconTextGap  = sm;

  // ── EdgeInsets presets ─────────────────────────────────────────
  static const EdgeInsets screenPadding =
      EdgeInsets.symmetric(horizontal: screenH, vertical: screenV);

  static const EdgeInsets cardPaddingAll =
      EdgeInsets.all(cardPadding);

  static const EdgeInsets tilePadding =
      EdgeInsets.symmetric(horizontal: tileH, vertical: tileV);

  static const EdgeInsets horizontalScreen =
      EdgeInsets.symmetric(horizontal: screenH);
}