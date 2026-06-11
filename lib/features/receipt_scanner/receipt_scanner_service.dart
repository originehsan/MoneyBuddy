// MoneyBuddy
import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

/// Scans a receipt image and extracts amount + description.
class ReceiptScannerService {
  static final _recognizer = TextRecognizer();
  static final _picker     = ImagePicker();

  // ── Pick image ────────────────────────────────────────────────

  static Future<File?> pickFromCamera() async {
    final picked = await _picker.pickImage(
      source:       ImageSource.camera,
      imageQuality: 85,
      maxWidth:     1920,
      maxHeight:    1920,
    );
    if (picked == null) return null;
    return File(picked.path);
  }

  static Future<File?> pickFromGallery() async {
    final picked = await _picker.pickImage(
      source:       ImageSource.gallery,
      imageQuality: 85,
      maxWidth:     1920,
      maxHeight:    1920,
    );
    if (picked == null) return null;
    return File(picked.path);
  }

  // ── Scan receipt ──────────────────────────────────────────────

  static Future<ScannedReceipt?> scanReceipt(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognized = await _recognizer.processImage(inputImage);
      return _parseReceipt(recognized.text);
    } catch (_) {
      return null;
    }
  }

  // ── Parse extracted text ──────────────────────────────────────

  static ScannedReceipt _parseReceipt(String text) {
    final lines  = text.split('\n').map((l) => l.trim()).toList();
    double? amount;
    String  description = '';

    // ── Amount extraction ─────────────────────────────────────
    // Look for patterns: ₹500, Rs.500, Total: 500, 500.00
    final amountPatterns = [
      RegExp(r'[₹Rs\.]+\s*(\d+(?:[.,]\d{1,2})?)'),   // ₹500 or Rs.500
      RegExp(r'(?:total|amount|grand\s*total|payable)'
             r'\s*[:\-]?\s*[₹Rs\.]*\s*(\d+(?:[.,]\d{1,2})?)',
             caseSensitive: false),                     // Total: 500
      RegExp(r'(\d{3,6}(?:\.\d{2})?)'),                // plain 500.00
    ];

    for (final pattern in amountPatterns) {
      for (final line in lines) {
        final match = pattern.firstMatch(line);
        if (match != null) {
          final raw = match.group(1)?.replaceAll(',', '') ?? '';
          final parsed = double.tryParse(raw);
          if (parsed != null && parsed > 0 && parsed < 1000000) {
            // Prefer larger amounts (likely the total)
            if (amount == null || parsed > amount) {
              amount = parsed;
            }
          }
        }
      }
      if (amount != null) break;
    }

    // ── Description extraction ────────────────────────────────
    // Use first non-empty, non-numeric line as description
    for (final line in lines) {
      if (line.isEmpty) continue;
      if (RegExp(r'^\d+$').hasMatch(line)) continue; // skip pure numbers
      if (line.length < 3) continue;                  // skip too short
      if (RegExp(r'[₹$]').hasMatch(line)) continue;   // skip amount lines
      description = _capitalize(line);
      break;
    }

    if (description.isEmpty) description = 'Receipt';

    return ScannedReceipt(
      amount:      amount,
      description: description,
      rawText:     text,
    );
  }

  static String _capitalize(String text) =>
      text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);

  static void dispose() => _recognizer.close();
}

/// Result of scanning a receipt.
class ScannedReceipt {
  final double? amount;
  final String  description;
  final String  rawText;

  const ScannedReceipt({
    required this.amount,
    required this.description,
    required this.rawText,
  });
}