// MoneyBuddy
import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  final _speech    = SpeechToText();
  bool _initialized = false;

  Future<bool> initialize() async {
    if (_initialized) return true;
    _initialized = await _speech.initialize(
      onError:  (_) {},
      onStatus: (_) {},
    );
    return _initialized;
  }

  /// Start listening.
  /// [onResult] called with each partial/final result.
  /// [onDone] called automatically when speech ends —
  /// no need to tap mic again.
  Future<void> startListening({
    required void Function(String text) onResult,
    required void Function()           onDone,
  }) async {
    final available = await initialize();
    if (!available) return;

    await _speech.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
        // Auto-close on final result — mic closes itself
        if (result.finalResult && result.recognizedWords.isNotEmpty) {
          onDone();
        }
      },
      listenOptions: SpeechListenOptions(
        listenFor:      const Duration(seconds: 30),
        pauseFor:       const Duration(seconds: 2), // 2s silence → done
        localeId:       'en_IN',
        cancelOnError:  true,
        partialResults: true,
      ),
    );
  }

  Future<void> stopListening() async => _speech.stop();

  bool get isListening => _speech.isListening;

  /// Parse spoken text → amount + description + type.
  static ParsedVoiceInput parse(String text) {
    final lower = text.toLowerCase().trim();

    // Extract first number
    final numMatch = RegExp(r'\d+(\.\d+)?').firstMatch(lower);
    final amount   = numMatch != null
        ? double.tryParse(numMatch.group(0)!)
        : null;

    // Extract description after keywords
    String description = text;
    final afterAt  = RegExp(r'\bat\s+(.+)$').firstMatch(lower);
    final afterOn  = RegExp(r'\bon\s+(.+)$').firstMatch(lower);
    final afterFor = RegExp(r'\bfor\s+(.+)$').firstMatch(lower);

    if (afterAt != null) {
      description = _capitalize(afterAt.group(1) ?? text);
    } else if (afterOn != null) {
      description = _capitalize(afterOn.group(1) ?? text);
    } else if (afterFor != null) {
      description = _capitalize(afterFor.group(1) ?? text);
    }

    description = description
        .replaceAll(RegExp(r'\d+(\.\d+)?'), '')
        .trim();
    if (description.isEmpty) description = text;

    final isIncome = RegExp(
      r'\b(received|got|earned|salary|income|credit|cashback|bonus)\b',
    ).hasMatch(lower);

    return ParsedVoiceInput(
      amount:      amount,
      description: description,
      isIncome:    isIncome,
    );
  }

  static String _capitalize(String text) =>
      text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);
}

class ParsedVoiceInput {
  final double? amount;
  final String  description;
  final bool    isIncome;

  const ParsedVoiceInput({
    required this.amount,
    required this.description,
    required this.isIncome,
  });
}