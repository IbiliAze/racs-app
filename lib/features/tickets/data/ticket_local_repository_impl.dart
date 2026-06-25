import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import 'package:reader/core/storage/local_database.dart';
import 'package:reader/features/tickets/data/ticket_dto.dart';
import 'package:reader/features/tickets/domain/ticket.dart';
import 'package:reader/features/tickets/domain/ticket_local_repository.dart';
import 'package:reader/features/tickets/domain/ticket_params.dart';

@Injectable(as: TicketLocalRepository)
class TicketLocalRepositoryImpl implements TicketLocalRepository {
  static const _table = 'tickets';

  final LocalDatabase _db;

  TicketLocalRepositoryImpl(this._db);

  @override
  Future<Ticket?> getTicketById(String id) async {
    final db = await _db.database;
    final rows = await db.query(_table, where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return TicketDto.fromMap(rows.first).toDomain();
  }

  @override
  Future<Ticket?> getTicketByLabel(String label) async {
    final db = await _db.database;
    final rows = await db.query(_table, where: 'label = ?', whereArgs: [label], limit: 1);
    if (rows.isEmpty) return null;
    return TicketDto.fromMap(rows.first).toDomain();
  }

  @override
  Future<Ticket?> getTicketByValue(String value) async {
    final db = await _db.database;
    final rows = await db.query(_table, where: 'value = ?', whereArgs: [value], limit: 1);
    if (rows.isEmpty) return null;
    return TicketDto.fromMap(rows.first).toDomain();
  }

  @override
  Future<List<Ticket>> getTickets(TicketParams params) async {
    final db = await _db.database;
    final offset = params.page != null && params.size != null
        ? params.page! * params.size!
        : null;
    final rows = await db.query(
      _table,
      where: 'eventId = ?',
      whereArgs: [params.eventId],
      limit: params.size,
      offset: offset,
      orderBy: 'createdAt DESC',
    );
    return rows.map((r) => TicketDto.fromMap(r).toDomain()).toList();
  }

  @override
  Future<int> countTickets(String eventId) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_table WHERE eventId = ?',
      [eventId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  @override
  Future<Ticket?> markUsed(String id) async {
    final db = await _db.database;
    final now = DateTime.now().toIso8601String();
    await db.update(
      _table,
      {'used': 1, 'usedAt': now},
      where: 'id = ?',
      whereArgs: [id],
    );
    return getTicketById(id);
  }

  @override
  Future<void> upsert(Ticket ticket) async {
    final db = await _db.database;
    await db.insert(
      _table,
      TicketDto.fromDomain(ticket).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> upsertFromMap(Map<String, dynamic> map) async {
    final db = await _db.database;
    await db.insert(
      _table,
      TicketDto.fromJson(map).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> upsertAll(List<Ticket> tickets) async {
    final db = await _db.database;
    final batch = db.batch();
    for (final ticket in tickets) {
      batch.insert(
        _table,
        TicketDto.fromDomain(ticket).toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<void> delete(String id) async {
    final db = await _db.database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}