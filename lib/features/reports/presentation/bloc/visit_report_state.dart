import 'package:equatable/equatable.dart';

import '../../domain/entities/visit_report.dart';

enum VisitReportStatus {
  initial,
  loading,
  success,
  failure,
}

class VisitReportState extends Equatable {
  final VisitReportStatus status;
  final List<VisitReport> reports;
  final String? errorMessage;

  const VisitReportState({
    this.status = VisitReportStatus.initial,
    this.reports = const [],
    this.errorMessage,
  });

  VisitReportState copyWith({
    VisitReportStatus? status,
    List<VisitReport>? reports,
    String? errorMessage,
    bool clearError = false,
  }) {
    return VisitReportState(
      status: status ?? this.status,
      reports: reports ?? this.reports,
      errorMessage:
          clearError
              ? null
              : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        reports,
        errorMessage,
      ];
}