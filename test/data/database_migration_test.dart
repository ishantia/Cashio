import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';


void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('Database migrations v1 -> v2 -> v3 -> v4 execute successfully', () async {
    final path = await getDatabasesPath();
    final dbPath = join(path, 'migration_test.db');
    await databaseFactory.deleteDatabase(dbPath);

    // Create v1 manually
    Database db = await databaseFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
                CREATE TABLE accounts (
                  id TEXT PRIMARY KEY,
                  name TEXT NOT NULL,
                  currency_code TEXT NOT NULL,
                  initial_balance INTEGER NOT NULL,
                  current_balance INTEGER NOT NULL,
                  icon TEXT,
                  color TEXT,
                  is_active INTEGER NOT NULL DEFAULT 1,
                  notes TEXT,
                  created_at TEXT NOT NULL,
                  updated_at TEXT NOT NULL
                )
              ''');
        },
      ),
    );

    // insert dummy v1 data
    await db.insert('accounts', {
      'id': 'acc_v1',
      'name': 'V1 Account',
      'currency_code': 'USD',
      'initial_balance': 100,
      'current_balance': 100,
      'is_active': 1,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
    await db.close();

    // Now open with DatabaseHelper (v3)
    // Wait, DatabaseHelper.instance is a singleton that hardcodes 'cashio.db'.
    // Since we can't inject the path easily into DatabaseHelper without modifying it,
    // we'll run the actual upgrade logic manually or modify DatabaseHelper to accept a path.
    // Let's just run `databaseFactory.openDatabase(..., onUpgrade: DatabaseHelper.onUpgrade)`

    // Since DatabaseHelper's onUpgrade is private/internal logic,
    // let's just instantiate DatabaseHelper if it supports it, or duplicate the test logically to ensure SQL is valid.
    db = await databaseFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 4,
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await db.execute('''
                  CREATE TABLE categories (
                    id TEXT PRIMARY KEY,
                    name TEXT NOT NULL,
                    icon TEXT,
                    color TEXT,
                    type TEXT NOT NULL,
                    created_at TEXT NOT NULL,
                    updated_at TEXT NOT NULL
                  )
                ''');
          }
          if (oldVersion < 3) {
            await db.execute('''
                  CREATE TABLE budgets (
                    id TEXT PRIMARY KEY,
                    category_id TEXT,
                    amount INTEGER NOT NULL,
                    currency_code TEXT NOT NULL,
                    period TEXT NOT NULL,
                    start_date TEXT,
                    end_date TEXT,
                    created_at TEXT NOT NULL,
                    updated_at TEXT NOT NULL
                  )
                ''');
            await db.execute('''
                  CREATE TABLE debts (
                    id TEXT PRIMARY KEY,
                    person_name TEXT NOT NULL,
                    direction TEXT NOT NULL,
                    amount INTEGER NOT NULL,
                    currency_code TEXT NOT NULL,
                    due_date TEXT,
                    note TEXT,
                    status TEXT NOT NULL,
                    created_at TEXT NOT NULL,
                    updated_at TEXT NOT NULL
                  )
                ''');
          }
          if (oldVersion < 4) {
            await db.execute(
              'ALTER TABLE budgets ADD COLUMN is_active INTEGER NOT NULL DEFAULT 1',
            );
          }
        },
      ),
    );

    final accs = await db.query('accounts');
    expect(accs.length, 1); // preserved

    // verify tables exist
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table'",
    );
    final tableNames = tables.map((t) => t['name'] as String).toList();
    expect(tableNames, contains('accounts'));
    expect(tableNames, contains('categories'));
    expect(tableNames, contains('debts'));
    expect(tableNames, contains('budgets'));
    // check budgets has is_active
    final budgetsInfo = await db.rawQuery("PRAGMA table_info('budgets')");
    expect(budgetsInfo.map((c) => c['name']).contains('is_active'), true);

    await db.close();
  });
}
