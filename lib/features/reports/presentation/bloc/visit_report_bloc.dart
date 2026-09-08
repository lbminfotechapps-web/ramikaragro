import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_visit_report.dart';
import 'visit_report_event.dart';
import 'visit_report_state.dart';

class VisitReportBloc
    extends Bloc<VisitReportEvent, VisitReportState> {
  final GetVisitReport getVisitReport;

  VisitReportBloc(
    this.getVisitReport,
  ) : super(const VisitReportState()) {
    on<GetVisitReportEvent>(_getVisitReport);
  }

  Future<void> _getVisitReport(
    GetVisitReportEvent event,
    Emitter<VisitReportState> emit,
  ) async {
    print('');
    print('==============================================');
    print('BLOC → GET VISIT REPORT');
    print('==============================================');

    print('User ID    : ${event.userId}');
    print('Log User ID: ${event.logUserId}');
    print('From Date  : ${event.fromDate}');
    print('To Date    : ${event.toDate}');

    print('==============================================');

    emit(
      state.copyWith(
        status: VisitReportStatus.loading,
        reports: [],
        clearError: true,
      ),
    );

    try {
      final reports = await getVisitReport(
        logUserId: event.logUserId,
        userId: event.userId,
        fromDate: event.fromDate,
        toDate: event.toDate,
      );

      print(
        'BLOC SUCCESS → ${reports.length} records',
      );

      emit(
        state.copyWith(
          status: VisitReportStatus.success,
          reports: reports,
          clearError: true,
        ),
      );
    } catch (e) {
      print('');
      print('==============================================');
      print('BLOC → VISIT REPORT FAILURE');
      print('==============================================');

      print(e);

      print('==============================================');

      emit(
        state.copyWith(
          status: VisitReportStatus.failure,
          reports: [],
          errorMessage: e.toString(),
        ),
      );
    }
  }
}