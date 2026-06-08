// MoneyBuddy
import 'package:math_expressions/math_expressions.dart';

/// Evaluates math expressions typed in amount fields.
/// Used for quick calculations without opening a separate calculator.
class CalculatorService {
  CalculatorService._();

  static final _parser    = GrammarParser();
  static final _evaluator = RealEvaluator();

  /// Returns formatted result string if input contains a math operator.
  /// Returns null if input is a plain number or invalid expression.
  static String? evaluate(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;
    if (!trimmed.contains(RegExp(r'[+\-*/]'))) return null;

    try {
      final result = _evaluator.evaluate(_parser.parse(trimmed)).toDouble();
      if (result.isNaN || result.isInfinite) return null;
      return '= ₹${result.toStringAsFixed(2)}';
    } catch (_) {
      return null;
    }
  }

  /// Resolves final amount from input — evaluates expression or parses number.
  static double? resolve(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;

    if (trimmed.contains(RegExp(r'[+\-*/]'))) {
      try {
        final result = _evaluator.evaluate(_parser.parse(trimmed)).toDouble();
        return result.isNaN || result.isInfinite ? null : result;
      } catch (_) {
        return null;
      }
    }

    return double.tryParse(trimmed);
  }
}