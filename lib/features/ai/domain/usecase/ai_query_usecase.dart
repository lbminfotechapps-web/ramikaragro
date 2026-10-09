import 'package:solufine/features/ai/domain/entity/ai_chat_response_entity.dart';
import 'package:solufine/features/ai/domain/repository/ai_repositoty.dart';

class AiQueryUsecase {
  final AiRepositoty aiRepositoty;

  AiQueryUsecase(this.aiRepositoty);

  Future<AiChatResponseEntity> askAiQuery({
    required String logUserId,
    required String question,
    required String format,
    required String usePrevious,
  }) {
    return aiRepositoty.askAiQuery(
      logUserId: logUserId,
      question: question,
      format: format,
      usePrevious: usePrevious,
    );
  }
}
