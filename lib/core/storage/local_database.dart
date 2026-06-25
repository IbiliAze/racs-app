import 'package:injectable/injectable.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

@lazySingleton
class LocalDatabase {
  static const _dbName = 'reader.db';
  static const _dbVersion = 1;

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
    await db.execute('''
      CREATE TABLE tickets (
        id TEXT PRIMARY KEY,
        eventId TEXT NOT NULL,
        value TEXT NOT NULL,
        label TEXT NOT NULL,
        type TEXT NOT NULL,
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
    await db.execute('''
      CREATE TABLE scans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        readerId TEXT NOT NULL,
        scannedValue TEXT NOT NULL,
        flag TEXT NOT NULL,
        ticketLabel TEXT,
        createdAt TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE dlq (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        scannedValue TEXT NOT NULL,
        flag TEXT NOT NULL,
        ticketId TEXT,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}