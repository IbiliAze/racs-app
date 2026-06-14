
import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import 'package:reader/core/storage/local_database.dart';
import 'package:reader/features/cards/data/card_dto.dart';
import 'package:reader/features/cards/domain/card.dart';
import 'package:reader/features/cards/domain/card_local_repository.dart';
import 'package:reader/features/cards/domain/card_params.dart';

@Injectable(as: CardLocalRepository)
class CardLocalRepositoryImpl implements CardLocalRepository {
  static const _table = 'cards';

  final LocalDatabase _db;

  CardLocalRepositoryImpl(this._db);

  @override
  Future<Card?> getCardById(String id) async {
    final db = await _db.database;
    final rows = await db.query(_table, where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return CardDto.fromMap(rows.first).toDomain();
  }

  @override
  Future<Card?> getCardByLabel(String label) async {
    final db = await _db.database;
    final rows = await db.query(_table, where: 'label = ?', whereArgs: [label], limit: 1);
    if (rows.isEmpty) return null;
    return CardDto.fromMap(rows.first).toDomain();
  }

  @override
  Future<Card?> getCardByValue(String value) async {
    final db = await _db.database;
    final rows = await db.query(_table, where: 'value = ?', whereArgs: [value], limit: 1);
    if (rows.isEmpty) return null;
    return CardDto.fromMap(rows.first).toDomain();
  }

  @override
  Future<List<Card>> getCards(CardParams params) async {
    final db = await _db.database;
    final offset = params.page != null && params.size != null
        ? params.page! * params.size!
        : null;
    final rows = await db.query(
      _table,
      where: 'ownerId = ?',
      whereArgs: [params.ownerId],
      limit: params.size,
      offset: offset,
      orderBy: 'createdAt DESC',
    );
    return rows.map((r) => CardDto.fromMap(r).toDomain()).toList();
  }

  @override
  Future<Card?> markUsed(String id) async {
    final db = await _db.database;
    final now = DateTime.now().toIso8601String();
    await db.update(
      _table,
      {'used': 1, 'usedAt': now},
      where: 'id = ?',
      whereArgs: [id],
    );
    return getCardById(id);
  }

  @override
  Future<void> upsert(Card card) async {
    final db = await _db.database;
    await db.insert(
      _table,
      CardDto.fromDomain(card).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> upsertAll(List<Card> cards) async {
    final db = await _db.database;
    final batch = db.batch();
    for (final card in cards) {
      batch.insert(
        _table,
        CardDto.fromDomain(card).toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }
}