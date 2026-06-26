import '../models/record.dart';

class DatabaseService {
  static final List<Record> _records = [];

  static Future<void> upsertRecord(Record r) async {
    final existingIndex = _records.indexWhere((rec) => rec.id == r.id);
    if (existingIndex >= 0) {
      if (_records[existingIndex].updatedAt >= r.updatedAt) return;
      _records[existingIndex] = r;
    } else {
      _records.add(r);
    }
  }

  static Future<List<Record>> listBySchema(String schema) async {
    final result = _records.where((r) => r.schema == schema).toList();
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result;
  }

  static Future<List<Record>> getAllRecords() async {
    final result = List<Record>.from(_records);
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result;
  }

  static Future<List<Record>> pendingRecords() async {
    return _records.where((r) => r.isPending).toList();
  }

  static Future<void> markSynced(String id) async {
    final index = _records.indexWhere((r) => r.id == id);
    if (index >= 0) {
      _records[index] = Record(
        id: _records[index].id,
        schema: _records[index].schema,
        langCode: _records[index].langCode,
        payload: _records[index].payload,
        createdAt: _records[index].createdAt,
        updatedAt: _records[index].updatedAt,
        deviceId: _records[index].deviceId,
        isPending: false,
        hopCount: _records[index].hopCount,
      );
    }
  }

  static Future<int> pendingCount() async {
    return _records.where((r) => r.isPending).length;
  }

  static Future<void> deleteRecord(String id) async {
    _records.removeWhere((r) => r.id == id);
  }
}
