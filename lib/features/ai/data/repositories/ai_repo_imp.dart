import 'package:solufine/features/ai/data/datasource/ai_datasource.dart';
import 'package:solufine/features/ai/domain/entity/ai_chat_response_entity.dart';
import 'package:solufine/features/ai/domain/repository/ai_repositoty.dart';

class AiRepoImp implements AiRepositoty {
  final AiDatasource aiDatasource;

  AiRepoImp(this.aiDatasource);
  @override
  Future<AiChatResponseEntity> askAiQuery({
    required String logUserId,
    required String question,
    required String format,
    required String usePrevious,
  }) {
    return aiDatasource.askAiQuery(logUserId, question, format, usePrevious);
  }
}
