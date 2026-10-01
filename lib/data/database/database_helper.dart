import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cashio.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE accounts (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        currency_code TEXT NOT NULL,
        initial_balance INTEGER NOT NULL,
        current_balance INTEGER NOT NULL,
        icon TEXT,
        color INTEGER,
        is_active INTEGER NOT NULL DEFAULT 1,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    if (version >= 2) await _createV2Tables(db);
    if (version >= 3) await _createV3Tables(db);
  }

  Future<void> _createV2Tables(Database db) async {
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        parent_id TEXT,
        icon TEXT,
        color INTEGER,
        is_default INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (parent_id) REFERENCES categories (id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        account_id TEXT NOT NULL,
        type TEXT NOT NULL,
        amount INTEGER NOT NULL,
        currency_code TEXT NOT NULL,
        category_id TEXT,
        transfer_id TEXT,
        linked_transaction_id TEXT,
        date TEXT NOT NULL,
        note TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (account_id) REFERENCES accounts (id) ON DELETE CASCADE,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE SET NULL
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_transactions_account ON transactions (account_id)',
    );
    await db.execute(
      'CREATE INDEX idx_transactions_date ON transactions (date)',
    );
    await db.execute(
      'CREATE INDEX idx_transactions_category ON transactions (category_id)',
    );
    await db.execute(
      'CREATE INDEX idx_transactions_type ON transactions (type)',
    );
    await db.execute(
      'CREATE INDEX idx_transactions_transfer ON transactions (transfer_id)',
    );
  }

  Future<void> _createV3Tables(Database db) async {
    // Add columns to transactions if it already exists (in migration)
    // In _createDB, since transactions was just created by V2, we might still need to alter it,
    // or we could have just updated V2. But to keep history clear, we just alter it here.
    // However, SQLite doesn't let us IF NOT EXISTS for columns easily in a single script without checking.
    // Wait, if it's a fresh DB (onCreate), _createV2Tables runs, creates transactions without debt_id.
    // Then _createV3Tables runs, and alters it. That's fine.

    await db.execute('ALTER TABLE transactions ADD COLUMN debt_id TEXT');
    await db.execute('ALTER TABLE transactions ADD COLUMN recurring_id TEXT');

    await db.execute('''
      CREATE TABLE recurring_transactions (
        id TEXT PRIMARY KEY,
        amount INTEGER NOT NULL,
        currency_code TEXT NOT NULL,
        account_id TEXT NOT NULL,
        category_id TEXT,
        type TEXT NOT NULL,
        note TEXT,
        start_date TEXT NOT NULL,
        end_date TEXT,
        recurrence_rule TEXT NOT NULL,
        next_occurrence TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (account_id) REFERENCES accounts (id) ON DELETE CASCADE,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE SET NULL
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

    await db.execute('''
      CREATE TABLE budgets (
        id TEXT PRIMARY KEY,
        category_id TEXT,
        amount INTEGER NOT NULL,
        currency_code TEXT NOT NULL,
        period TEXT NOT NULL,
        start_date TEXT,
        end_date TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE SET NULL
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_transactions_debt ON transactions (debt_id)',
    );
    await db.execute(
      'CREATE INDEX idx_transactions_recurring ON transactions (recurring_id)',
    );
    await db.execute(
      'CREATE INDEX idx_recurring_next ON recurring_transactions (next_occurrence)',
    );
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) await _createV2Tables(db);
    if (oldVersion < 3) await _createV3Tables(db);
    if (oldVersion < 4) {
      await db.execute(
        'ALTER TABLE budgets ADD COLUMN is_active INTEGER NOT NULL DEFAULT 1',
      );
    }
  }
}
