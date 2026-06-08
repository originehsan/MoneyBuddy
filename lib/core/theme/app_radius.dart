import 'package:flutter/material.dart';

/// MoneyBuddy — Border Radius System
/// Usage: Container(decoration: BoxDecoration(borderRadius: AppRadius.card))
class AppRadius {
  AppRadius._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double full = 999;

  // ── BorderRadius presets ───────────────────────────────────────
  static const BorderRadius tag = BorderRadius.all(Radius.circular(xs));

  static const BorderRadius input = BorderRadius.all(Radius.circular(sm));

  static const BorderRadius tile = BorderRadius.all(Radius.circular(md));

  static const BorderRadius card = BorderRadius.all(Radius.circular(lg));

  static const BorderRadius cardLarge = BorderRadius.all(Radius.circular(xl));

  static const BorderRadius modal = BorderRadius.all(Radius.circular(xxl));

  static const BorderRadius pill = BorderRadius.all(Radius.circular(full));

  static const BorderRadius button = BorderRadius.all(Radius.circular(md));

  static const BorderRadius buttonLarge = BorderRadius.all(Radius.circular(14));

  static const BorderRadius bottomSheet = BorderRadius.only(
    topLeft: Radius.circular(xxl),
    topRight: Radius.circular(xxl),
  );

  // Green header bottom corners — add transaction, add group screens

  static const BorderRadius topBar = BorderRadius.only(
    bottomLeft: Radius.circular(xxl),
    bottomRight: Radius.circular(xxl),
  );
}
