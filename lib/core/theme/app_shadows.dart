import 'package:flutter/material.dart';

/// MoneyBuddy — Shadow System
/// Usage: Container(decoration: BoxDecoration(boxShadow: AppShadows.card))
class AppShadows {
  AppShadows._();

  /// Transaction tiles, stat cards
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  /// Balance card, hero cards
  static const List<BoxShadow> cardMedium = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  /// Modals, bottom sheets
  static const List<BoxShadow> modal = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  /// Floating action button
  static const List<BoxShadow> fab = [
    BoxShadow(
      color: Color(0x3305966A),
      blurRadius: 20,
      offset: Offset(0, 6),
    ),
  ];

  /// Primary button subtle glow
  static const List<BoxShadow> primaryGlow = [
    BoxShadow(
      color: Color(0x2605966A),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> none = [];
}