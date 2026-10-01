import '../../domain/services/csv_export_service.dart';
import '../database/database_helper.dart';

class SqfliteCsvExportService implements CsvExportService {
  final DatabaseHelper _dbHelper;

  SqfliteCsvExportService(this._dbHelper);

  @override
  Future<String> exportTransactionsToCsv() async {
    final db = await _dbHelper.database;

    final result = await db.rawQuery('''
      SELECT 
        t.date,
        t.type,
        t.amount,
        t.currency_code,
        a.name as account_name,
        c.name as category_name,
        t.note,
        t.transfer_id,
        t.debt_id,
        t.recurring_id
      FROM transactions t
      LEFT JOIN accounts a ON t.account_id = a.id
      LEFT JOIN categories c ON t.category_id = c.id
      ORDER BY t.date DESC
    ''');

    final buffer = StringBuffer();
    buffer.writeln(
      'Date,Type,Amount,Currency,Account,Category,Note,Transfer ID,Debt ID,Recurring ID',
    );

    String escapeCsv(String value) {
      if (value.contains(',') || value.contains('"') || value.contains('\n')) {
        final escaped = value.replaceAll('"', '""');
        return '"$escaped"';
      }
      return value;
    }

    for (final row in result) {
      final date = row['date']?.toString() ?? '';
      final type = row['type']?.toString() ?? '';
      final amount = row['amount']?.toString() ?? '';
      final currency = row['currency_code']?.toString() ?? '';
      final acc = escapeCsv(row['account_name']?.toString() ?? '');
      final cat = escapeCsv(row['category_name']?.toString() ?? '');
      final note = escapeCsv(row['note']?.toString() ?? '');
      final tId = escapeCsv(row['transfer_id']?.toString() ?? '');
      final dId = escapeCsv(row['debt_id']?.toString() ?? '');
      final rId = escapeCsv(row['recurring_id']?.toString() ?? '');

      buffer.writeln(
        "$date,$type,$amount,$currency,$acc,$cat,$note,$tId,$dId,$rId",
      );
    }

    return buffer.toString();
  }
}
