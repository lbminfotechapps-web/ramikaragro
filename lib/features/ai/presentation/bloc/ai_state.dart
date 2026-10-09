
import 'package:equatable/equatable.dart';
import 'package:solufine/features/ai/domain/entity/ai_chat_response_entity.dart';


// ============================================================
// AI STATUS
// ============================================================

enum AiStatus {
  initial,
  loading,
  success,
  failure,
}

// ============================================================
// AI STATE
// ============================================================

class AiState extends Equatable {
  final AiStatus aiStatus;

  final AiChatResponseEntity? aiResponse;

  final String? errorMessage;

  const AiState({
    this.aiStatus = AiStatus.initial,
    this.aiResponse,
    this.errorMessage,
  });

  AiState copyWith({
    AiStatus? aiStatus,
    AiChatResponseEntity? aiResponse,
    String? errorMessage,
    bool clearResponse = false,
    bool clearError = false,
  }) {
    return AiState(
      aiStatus: aiStatus ?? this.aiStatus,
      aiResponse: clearResponse
          ? null
          : aiResponse ?? this.aiResponse,
      errorMessage: clearError
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        aiStatus,
        aiResponse,
        errorMessage,
      ];
}
