
import 'package:equatable/equatable.dart';

abstract class AiEvent extends Equatable {
  const AiEvent();

  @override
  List<Object?> get props => [];
}

// ============================================================
// ASK AI QUERY EVENT
// ============================================================

class AskQueryEvent extends AiEvent {
  final String logUserId;
  final String question;
  final String format;
  final String usePrevious;

  const AskQueryEvent({
    required this.logUserId,
    required this.question,
    required this.format,
    required this.usePrevious,
  });

  @override
  List<Object?> get props => [
        logUserId,
        question,
        format,
        usePrevious,
      ];
}

// ============================================================
// RESET AI STATE
// ============================================================

class ResetAiEvent extends AiEvent {
  const ResetAiEvent();
}
