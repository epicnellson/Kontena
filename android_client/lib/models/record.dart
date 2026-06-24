import 'package:uuid/uuid.dart';

class Record {
  final String id;
  final String schema;
  final String langCode;
  final String payload;
  final int createdAt;
  final int updatedAt;
  final String deviceId;
  bool isPending;
  int hopCount;

  Record({
    String? id,
    required this.schema,
    required this.langCode,
    required this.payload,
    int? createdAt,
    int? updatedAt,
    required this.deviceId,
    this.isPending = true,
    this.hopCount = 0,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch,
        updatedAt = updatedAt ?? DateTime.now().millisecondsSinceEpoch;

  Map<String, dynamic> toMap() => {
        'id': id,
        'schema': schema,
        'lang_code': langCode,
        'payload': payload,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'device_id': deviceId,
        'is_pending': isPending ? 1 : 0,
        'hop_count': hopCount,
      };

  Map<String, dynamic> toJson() => {
        'id': id,
        'schema': schema,
        'lang_code': langCode,
        'payload': payload,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'device_id': deviceId,
        'hop_count': hopCount,
      };

  factory Record.fromMap(Map<String, dynamic> m) => Record(
        id: m['id'] as String,
        schema: m['schema'] as String,
        langCode: m['lang_code'] as String? ?? '',
        payload: m['payload'] as String? ?? '',
        createdAt: m['created_at'] as int? ?? 0,
        updatedAt: m['updated_at'] as int? ?? 0,
        deviceId: m['device_id'] as String? ?? '',
        isPending: (m['is_pending'] as int? ?? 1) == 1,
        hopCount: m['hop_count'] as int? ?? 0,
      );
}
