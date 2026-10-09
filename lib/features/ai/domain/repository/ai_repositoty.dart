import 'package:solufine/features/ai/domain/entity/ai_chat_response_entity.dart';

abstract class AiRepositoty {
  Future<AiChatResponseEntity> askAiQuery({
    required String logUserId,
    required String question,
    required String format,
    required String usePrevious,
  });
}
