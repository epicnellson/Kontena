import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/record.dart';

class DatabaseService {
  static Database? _db;

  static Future<Database> get db async {
    _db ??= await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'kontena.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE records (
            id         TEXT PRIMARY KEY,
            schema     TEXT NOT NULL,
            lang_code  TEXT NOT NULL DEFAULT "",
            payload    TEXT NOT NULL DEFAULT "",
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            device_id  TEXT NOT NULL DEFAULT "",
            is_pending INTEGER NOT NULL DEFAULT 1,
            hop_count  INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await db.execute(
          'CREATE INDEX idx_schema ON records(schema)');
        await db.execute(
          'CREATE INDEX idx_pending ON records(is_pending)');
      },
    );
  }

  static Future<void> upsertRecord(Record r) async {
    final d = await db;
    // Last-write-wins: only replace if incoming is newer
    final existing = await d.query(
      'records', where: 'id=?', whereArgs: [r.id], columns: ['updated_at'],
    );
    if (existing.isNotEmpty) {
      final existingTs = existing.first['updated_at'] as int;
      if (existingTs >= r.updatedAt) return;
    }
    await d.insert('records', r.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Record>> listBySchema(String schema) async {
    final rows = await (await db).query(
      'records',
      where: 'schema=?',
      whereArgs: [schema],
      orderBy: 'created_at DESC',
    );
    return rows.map(Record.fromMap).toList();
  }

  static Future<List<Record>> getAllRecords() async {
    final rows = await (await db).query(
        'records', orderBy: 'created_at DESC');
    return rows.map(Record.fromMap).toList();
  }

  static Future<List<Record>> pendingRecords() async {
    final rows = await (await db).query(
        'records', where: 'is_pending=1');
    return rows.map(Record.fromMap).toList();
  }

  static Future<void> markSynced(String id) async {
    await (await db).update(
      'records',
      {'is_pending': 0},
      where: 'id=?',
      whereArgs: [id],
    );
  }

  static Future<int> pendingCount() async {
    final result = await (await db)
        .rawQuery('SELECT COUNT(*) as c FROM records WHERE is_pending=1');
    return (result.first['c'] as int?) ?? 0;
  }

  static Future<void> deleteRecord(String id) async {
    await (await db).delete('records', where: 'id=?', whereArgs: [id]);
  }
}
