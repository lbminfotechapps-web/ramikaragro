
import 'package:solufine/features/ai/domain/entity/ai_chat_response_entity.dart';



class AiChatResponseModel extends AiChatResponseEntity {
  const AiChatResponseModel({
    required super.status,
    required super.message,
    required super.format,
    required super.result,
  });

  factory AiChatResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final format =
        json['format']?.toString().toLowerCase() ?? 'table';

    final rawResult = json['result'];

    final resultJson = rawResult is Map
        ? Map<String, dynamic>.from(rawResult)
        : <String, dynamic>{};

    return AiChatResponseModel(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      format: format,
      result: AiChatResultModel.fromJson(
        resultJson,
        format,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'format': format,
      'result': AiChatResultModel.fromEntity(result)
          .toJson(format),
    };
  }
}

// ============================================================
// RESULT MODEL
// ============================================================

class AiChatResultModel extends AiChatResultEntity {
  const AiChatResultModel({
    super.labels,
    super.values,
    super.columns,
    super.rows,
    super.totalRows,
  });

  factory AiChatResultModel.fromJson(
    Map<String, dynamic> json,
    String format,
  ) {
    if (format == 'graph') {
      return AiChatResultModel(
        labels: (json['labels'] as List? ?? [])
            .map((e) => e?.toString() ?? '')
            .toList(),
        values: (json['values'] as List? ?? [])
            .map((e) => _parseDouble(e))
            .toList(),
      );
    }

    return AiChatResultModel(
      columns: (json['columns'] as List? ?? [])
          .whereType<Map>()
          .map(
            (e) => AiChatColumnModel.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList(),
      rows: (json['rows'] as List? ?? [])
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList(),
      totalRows: int.tryParse(
            json['total_rows']?.toString() ?? '',
          ) ??
          0,
    );
  }

  factory AiChatResultModel.fromEntity(
    AiChatResultEntity entity,
  ) {
    return AiChatResultModel(
      labels: entity.labels,
      values: entity.values,
      columns: entity.columns,
      rows: entity.rows,
      totalRows: entity.totalRows,
    );
  }

  Map<String, dynamic> toJson(String format) {
    if (format == 'graph') {
      return {
        'labels': labels,
        'values': values,
      };
    }

    return {
      'columns': columns
          .map(
            (e) => {
              'key': e.key,
              'label': e.label,
            },
          )
          .toList(),
      'rows': rows,
      'total_rows': totalRows,
    };
  }

  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();

    return double.tryParse(
          value?.toString().replaceAll(',', '') ?? '',
        ) ??
        0.0;
  }
}

// ============================================================
// COLUMN MODEL
// ============================================================

class AiChatColumnModel extends AiChatColumnEntity {
  const AiChatColumnModel({
    required super.key,
    required super.label,
  });

  factory AiChatColumnModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AiChatColumnModel(
      key: json['key']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'label': label,
    };
  }
}
