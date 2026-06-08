// MoneyBuddy
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../features/transactions/models/transaction_model.dart';
import '../../core/utils/formatters.dart';

/// Converts transactions to CSV and shares via device share sheet.
///
/// Usage:
///   await CsvExportService.export(transactions);
class CsvExportService {
  CsvExportService._();

  /// Exports transaction list as CSV file and opens share sheet.
  static Future<void> export(List<TransactionModel> transactions) async {
    if (transactions.isEmpty) {
      throw Exception('No transactions to export');
    }

    final csv  = _buildCsv(transactions);
    final file = await _saveToTemp(csv);

    await SharePlus.instance.share(
      ShareParams(
        files:   [XFile(file.path)],
        subject: 'MoneyBuddy Transactions',
        text:    'My transaction history from MoneyBuddy',
      ),
    );
  }

  /// Builds CSV string from transaction list.
  static String _buildCsv(List<TransactionModel> transactions) {
    final buffer = StringBuffer();

    buffer.writeln('Date,Type,Category,Description,Amount');

    for (final tx in transactions) {
      final date        = AppFormatters.formatDate(tx.date);
      final type        = tx.type;
      final category    = tx.category ?? tx.type;
      final description = _escapeCsv(tx.description);
      final amount      = tx.amount.toStringAsFixed(2);

      buffer.writeln('$date,$type,$category,$description,$amount');
    }

    return buffer.toString();
  }

  /// Saves CSV string to temp directory and returns the file.
  static Future<File> _saveToTemp(String csv) async {
    final dir       = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file      = File('${dir.path}/moneybuddy_$timestamp.csv');
    await file.writeAsString(csv);
    return file;
  }

  /// Wraps field in quotes if it contains comma, quote, or newline.
  static String _escapeCsv(String value) {
    if (value.contains(',') ||
        value.contains('"') ||
        value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}