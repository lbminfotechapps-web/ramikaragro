import 'package:drift/drift.dart';
import 'package:solufine/core/location_tracking/app_database.dart';

class AiChatDatabaseOperations {
  final AppDatabase database;

  AiChatDatabaseOperations(this.database);

  // ============================================================
  // 1. CREATE NEW CHAT SESSION
  // ============================================================

  Future<int> createChatSession({
    required int userId,
    required String title,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    return database
        .into(database.aiChatSessions)
        .insert(
          AiChatSessionsCompanion.insert(
            userId: userId,
            title: title,
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  // ============================================================
  // 2. SAVE CHAT MESSAGE
  // ============================================================

  Future<int> insertChatMessage({
    required int sessionId,
    required String message,
    required bool isUser,
    String outputType = 'text',
    String responseData = '',
  }) async {
    return database.transaction(() async {
      final now = DateTime.now().millisecondsSinceEpoch;

      // Verify session exists.
      final session = await (database.select(
        database.aiChatSessions,
      )..where((t) => t.id.equals(sessionId))).getSingleOrNull();

      if (session == null) {
        throw StateError('Chat session does not exist');
      }

      // Insert message.
      final messageId = await database
          .into(database.aiChatMessages)
          .insert(
            AiChatMessagesCompanion.insert(
              sessionId: sessionId,
              message: message,
              isUser: isUser,
              outputType: Value(outputType),
              responseData: Value(responseData),
              createdAt: now,
            ),
          );

      // Update session's last activity time.
      await (database.update(database.aiChatSessions)
            ..where((t) => t.id.equals(sessionId)))
          .write(AiChatSessionsCompanion(updatedAt: Value(now)));

      return messageId;
    });
  }

  // ============================================================
  // 3. GET ALL CHAT SESSIONS FOR USER
  // ============================================================

  Future<List<AiChatSession>> getChatSessions(int userId) {
    return (database.select(database.aiChatSessions)
          ..where((t) => t.userId.equals(userId))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc),
          ]))
        .get();
  }

  // ============================================================
  // 4. GET MESSAGES OF SELECTED CHAT
  // ============================================================

  Future<List<AiChatMessage>> getChatMessages({
    required int sessionId,
    required int userId,
  }) async {
    // Check that session belongs to user.
    final session =
        await (database.select(database.aiChatSessions)
              ..where((t) => t.id.equals(sessionId) & t.userId.equals(userId)))
            .getSingleOrNull();

    if (session == null) {
      return [];
    }

    return (database.select(database.aiChatMessages)
          ..where((t) => t.sessionId.equals(sessionId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.id, mode: OrderingMode.asc),
          ]))
        .get();
  }

  // ============================================================
  // 5. DELETE INDIVIDUAL CHAT + ITS MESSAGES
  // ============================================================

  Future<void> deleteChatSession({
    required int sessionId,
    required int userId,
  }) async {
    await database.transaction(() async {
      // Check user ownership.
      final session =
          await (database.select(
                database.aiChatSessions,
              )..where((t) => t.id.equals(sessionId) & t.userId.equals(userId)))
              .getSingleOrNull();

      if (session == null) {
        return;
      }

      // Delete all messages of this session.
      await (database.delete(
        database.aiChatMessages,
      )..where((t) => t.sessionId.equals(sessionId))).go();

      // Delete session.
      await (database.delete(
        database.aiChatSessions,
      )..where((t) => t.id.equals(sessionId))).go();
    });
  }

  // ============================================================
  // 6. UPDATE CHAT TITLE
  // ============================================================

  Future<void> updateChatTitle({
    required int sessionId,
    required int userId,
    required String title,
  }) async {
    await (database.update(database.aiChatSessions)
          ..where((t) => t.id.equals(sessionId) & t.userId.equals(userId)))
        .write(AiChatSessionsCompanion(title: Value(title)));
  }

  // ============================================================
  // 7. DELETE ALL CHAT HISTORY FOR A USER
  // ============================================================

  Future<void> deleteAllUserChatHistory({required int userId}) async {
    await database.transaction(() async {
      final sessions = await (database.select(
        database.aiChatSessions,
      )..where((t) => t.userId.equals(userId))).get();

      if (sessions.isEmpty) {
        return;
      }

      final sessionIds = sessions.map((session) => session.id).toList();

      // Delete messages first.
      await (database.delete(
        database.aiChatMessages,
      )..where((t) => t.sessionId.isIn(sessionIds))).go();

      // Delete sessions.
      await (database.delete(
        database.aiChatSessions,
      )..where((t) => t.userId.equals(userId))).go();
    });
  }

  // ============================================================
  // 8. AUTOMATICALLY DELETE CHAT HISTORY OLDER THAN 8 DAYS
  // ============================================================

  Future<int> cleanupOldChatHistory() async {
    final cutoff = DateTime.now()
        .subtract(const Duration(days: 8))
        .millisecondsSinceEpoch;

    return database.transaction(() async {
      // Find chats inactive for 8 days.
      final expiredSessions = await (database.select(
        database.aiChatSessions,
      )..where((t) => t.updatedAt.isSmallerOrEqualValue(cutoff))).get();

      if (expiredSessions.isEmpty) {
        return 0;
      }

      final expiredIds = expiredSessions.map((session) => session.id).toList();

      // Delete messages belonging to expired sessions.
      await (database.delete(
        database.aiChatMessages,
      )..where((t) => t.sessionId.isIn(expiredIds))).go();

      // Delete expired chat sessions.
      final deletedCount = await (database.delete(
        database.aiChatSessions,
      )..where((t) => t.id.isIn(expiredIds))).go();

      return deletedCount;
    });
  }
}
