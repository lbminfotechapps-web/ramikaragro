import 'package:drift/drift.dart';

// ============================================================
// AI CHAT SESSIONS
// ============================================================

class AiChatSessions extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get userId => integer()();

  TextColumn get title => text()();

  IntColumn get createdAt => integer()();

  IntColumn get updatedAt => integer()();
}

// ============================================================
// AI CHAT MESSAGES
// ============================================================

class AiChatMessages extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get sessionId => integer()();

  TextColumn get message => text()();

  BoolColumn get isUser => boolean()();

  TextColumn get outputType => text().withDefault(const Constant('text'))();

  TextColumn get responseData => text().withDefault(const Constant(''))();

  IntColumn get createdAt => integer()();
}
