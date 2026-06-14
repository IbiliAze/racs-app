import 'package:injectable/injectable.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

@lazySingleton
class LocalDatabase {
  static const _dbName = 'reader.db';
  static const _dbVersion = 5;

  Database? _db;

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        message TEXT NOT NULL,
        level TEXT NOT NULL,
        className TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');
    await _createCardsTable(db);
    await _createScansTable(db);
    await _createDlqTable(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) await _createCardsTable(db);
    if (oldVersion < 3) await _createScansTable(db);
    if (oldVersion < 4) await _createDlqTable(db);
    if (oldVersion < 5) {
      await db.execute('DROP TABLE IF EXISTS dlq');
      await _createDlqTable(db);
    }
  }

  Future<void> _createScansTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS scans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        readerId TEXT NOT NULL,
        scannedValue TEXT NOT NULL,
        flag TEXT NOT NULL,
        cardLabel TEXT,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createCardsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS cards (
        id TEXT PRIMARY KEY,
        locationId TEXT NOT NULL,
        value TEXT NOT NULL,
        label TEXT NOT NULL,
        type TEXT NOT NULL,
        ownerId TEXT NOT NULL,
        validFrom TEXT,
        validUntil TEXT,
        metadata TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        usedAt TEXT,
        used INTEGER NOT NULL DEFAULT 0,
        invalidated INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<void> _createDlqTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS dlq (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        scannedValue TEXT NOT NULL,
        flag TEXT NOT NULL,
        cardId TEXT,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}