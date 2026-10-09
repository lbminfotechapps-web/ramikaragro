import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solufine/features/ai/domain/usecase/ai_query_usecase.dart';

import 'ai_event.dart';
import 'ai_state.dart';

class AiBloc extends Bloc<AiEvent, AiState> {
  final AiQueryUsecase aiQueryUsecase;

  AiBloc(this.aiQueryUsecase) : super(const AiState()) {
    on<AskQueryEvent>(_onAskQuery);

    on<ResetAiEvent>(_onResetAi);
  }

  Future<void> _onAskQuery(AskQueryEvent event, Emitter<AiState> emit) async {
    emit(
      state.copyWith(
        aiStatus: AiStatus.loading,
        clearResponse: true,
        clearError: true,
      ),
    );

    try {
      debugPrint('AI BLOC: Sending question: ${event.question}');

      final response = await aiQueryUsecase.askAiQuery(
        logUserId: event.logUserId,
        question: event.question,
        format: event.format,
        usePrevious: event.usePrevious,
      );

      // API response received successfully.
      emit(
        state.copyWith(
          aiStatus: AiStatus.success,
          aiResponse: response,
          clearError: true,
        ),
      );

      debugPrint('AI BLOC: Status = ${response.status}');
      debugPrint('AI BLOC: Message = ${response.message}');
      debugPrint('AI BLOC: Format = ${response.format}');
      debugPrint('AI BLOC: Total Rows = ${response.result.totalRows}');
    } catch (e, stackTrace) {
      debugPrint('AI BLOC ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);

      emit(
        state.copyWith(
          aiStatus: AiStatus.failure,
          errorMessage: e.toString(),
          clearResponse: true,
        ),
      );
    }
  }

  void _onResetAi(ResetAiEvent event, Emitter<AiState> emit) {
    emit(const AiState());
  }
}
