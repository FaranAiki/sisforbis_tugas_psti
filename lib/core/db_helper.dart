import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'sisforbis.db');
    return await openDatabase(
      path,
      version: 3, // Upgraded version for HR & Expenses
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        stock INTEGER,
        price REAL
      )
    ''');
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        itemId INTEGER,
        quantity INTEGER,
        type TEXT,
        date TEXT,
        totalPrice REAL,
        subtotal REAL,
        ppnAmount REAL,
        FOREIGN KEY (itemId) REFERENCES items (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE queue_tickets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ticket_number INTEGER,
        status TEXT,
        timestamp TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT,
        phone TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE interactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customerId INTEGER,
        note TEXT,
        rating INTEGER,
        date TEXT,
        FOREIGN KEY (customerId) REFERENCES customers (id)
      )
    ''');

    // HR Table
    await db.execute('''
      CREATE TABLE employees (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        role TEXT,
        salary REAL,
        joinedDate TEXT
      )
    ''');

    // Expenses Table
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT,
        note TEXT,
        amount REAL,
        date TEXT
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE transactions ADD COLUMN subtotal REAL DEFAULT 0');
      await db.execute('ALTER TABLE transactions ADD COLUMN ppnAmount REAL DEFAULT 0');
      await db.execute('UPDATE transactions SET subtotal = totalPrice WHERE subtotal = 0');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE employees (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          role TEXT,
          salary REAL,
          joinedDate TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE expenses (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          category TEXT,
          note TEXT,
          amount REAL,
          date TEXT
        )
      ''');
    }
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('items');
    await db.delete('transactions');
    await db.delete('queue_tickets');
    await db.delete('customers');
    await db.delete('interactions');
    await db.delete('employees');
    await db.delete('expenses');
  }
}
