
class AiChatResponseEntity {
  final bool status;
  final String message;
  final String format;
  final AiChatResultEntity result;

  const AiChatResponseEntity({
    required this.status,
    required this.message,
    required this.format,
    required this.result,
  });
}

class AiChatResultEntity {
  // Graph response
  final List<String> labels;
  final List<double> values;

  // Table response
  final List<AiChatColumnEntity> columns;
  final List<Map<String, dynamic>> rows;
  final int totalRows;

  const AiChatResultEntity({
    this.labels = const [],
    this.values = const [],
    this.columns = const [],
    this.rows = const [],
    this.totalRows = 0,
  });
}

class AiChatColumnEntity {
  final String key;
  final String label;

  const AiChatColumnEntity({
    required this.key,
    required this.label,
  });
}
