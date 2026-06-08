// MoneyBuddy
import 'package:intl/intl.dart';

/// All formatting utilities.
/// Usage: AppFormatters.formatCurrency(24350.0) → '₹24,350.00'
class AppFormatters {
  AppFormatters._();

  // ── Currency ──────────────────────────────────────────────────
  static final _currencyFull = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final _currencyCompact = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  /// ₹24,350.00
  static String formatCurrency(double amount) =>
      _currencyFull.format(amount);

  /// ₹24,350
  static String formatCurrencyCompact(double amount) =>
      _currencyCompact.format(amount);

  /// +₹24,350.00 or -₹24,350.00
  static String formatTransactionAmount(double amount, String type) {
    final formatted = formatCurrency(amount.abs());
    return type.toLowerCase() == 'income' ? '+$formatted' : '-$formatted';
  }

  // ── Date ──────────────────────────────────────────────────────

  /// Dec 1, 2024
  static String formatDate(DateTime date) =>
      DateFormat('MMM d, yyyy').format(date);

  /// Today / Yesterday / Dec 1
  static String formatRelativeDate(DateTime date) {
    final now     = DateTime.now();
    final today   = DateTime(now.year, now.month, now.day);
    final target  = DateTime(date.year, date.month, date.day);
    final diff    = today.difference(target).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return DateFormat('MMM d').format(date);
  }

  /// 1:30 PM
  static String formatTime(DateTime date) =>
      DateFormat('h:mm a').format(date);

  /// Today, 1:30 PM
  static String formatDateTime(DateTime date) =>
      '${formatRelativeDate(date)}, ${formatTime(date)}';

  /// Jan 2024
  static String formatMonthYear(DateTime date) =>
      DateFormat('MMM yyyy').format(date);

  /// Parse ISO string safely
  static DateTime? parseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }

  // ── Numbers ───────────────────────────────────────────────────

  /// 24350 → 24.3K, 1500000 → 1.5M
  static String formatCompactNumber(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000)    return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toStringAsFixed(0);
  }

  // ── Greeting ──────────────────────────────────────────────────
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}