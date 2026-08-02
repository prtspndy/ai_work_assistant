import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('vyapar_mitra.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const taskTableSql = '''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        instruction_type TEXT NOT NULL,
        customer_name TEXT,
        action TEXT,
        item_name TEXT,
        quantity REAL,
        quantity_unit TEXT,
        amount REAL,
        currency TEXT DEFAULT 'INR',
        due_date TEXT,
        due_time TEXT,
        payment_status TEXT NOT NULL DEFAULT 'pending',
        task_status TEXT NOT NULL DEFAULT 'pending',
        next_action TEXT,
        notes TEXT,
        original_instruction TEXT NOT NULL,
        recognized_text TEXT NOT NULL,
        generated_message TEXT NOT NULL,
        language_code TEXT NOT NULL,
        confidence REAL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''';

    await db.execute(taskTableSql);

    // Create Indexes for faster queries and history grouping
    await db.execute('CREATE INDEX idx_tasks_created_at ON tasks(created_at DESC)');
    await db.execute('CREATE INDEX idx_tasks_due_date ON tasks(due_date)');
    await db.execute('CREATE INDEX idx_tasks_task_status ON tasks(task_status)');
    await db.execute('CREATE INDEX idx_tasks_payment_status ON tasks(payment_status)');
    await db.execute('CREATE INDEX idx_tasks_customer ON tasks(customer_name)');
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
