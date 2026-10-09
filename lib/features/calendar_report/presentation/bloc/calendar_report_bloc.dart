import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/calendar_day_entity.dart';
import '../../domain/usecases/get_calendar_report_usecase.dart';

import 'calendar_report_event.dart';
import 'calendar_report_state.dart';

class CalendarReportBloc
    extends Bloc<
        CalendarReportEvent,
        CalendarReportState> {
  final GetCalendarReportUseCase
      getCalendarReportUseCase;

  CalendarReportBloc({
    required this.getCalendarReportUseCase,
  }) : super(
          CalendarReportState(
            visibleMonth: DateTime(
              DateTime.now().year,
              DateTime.now().month,
              1,
            ),
          ),
        ) {
    on<LoadCalendarReportEvent>(
      _loadCalendar,
    );

    on<PreviousCalendarMonthEvent>(
      _previousMonth,
    );

    on<NextCalendarMonthEvent>(
      _nextMonth,
    );

    on<TodayCalendarEvent>(
      _today,
    );
  }

  // ============================================================
  // LOAD
  // ============================================================

  Future<void> _loadCalendar(
    LoadCalendarReportEvent event,
    Emitter<CalendarReportState> emit,
  ) async {
    final DateTime visibleMonth =
        DateTime(
      event.month.year,
      event.month.month,
      1,
    );

    emit(
      state.copyWith(
        status:
            CalendarReportStatus.loading,

        visibleMonth:
            visibleMonth,

        clearError:
            true,
      ),
    );

    try {
      final String month =
          DateFormat(
        'yyyy-MM',
      ).format(
        visibleMonth,
      );

      final List<CalendarDayEntity>
          result =
          await getCalendarReportUseCase(
        userId:
            event.userId,

        month:
            month,
      );

      emit(
        state.copyWith(
          status:
              CalendarReportStatus.success,

          visibleMonth:
              visibleMonth,

          days:
              result,

          clearError:
              true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status:
              CalendarReportStatus.failure,

          visibleMonth:
              visibleMonth,

          days:
              const [],

          errorMessage:
              e
                  .toString()
                  .replaceFirst(
                    'Exception: ',
                    '',
                  ),
        ),
      );
    }
  }

  // ============================================================
  // PREVIOUS
  // ============================================================

  void _previousMonth(
    PreviousCalendarMonthEvent event,
    Emitter<CalendarReportState> emit,
  ) {
    final DateTime previous =
        DateTime(
      state.visibleMonth.year,
      state.visibleMonth.month - 1,
      1,
    );

    add(
      LoadCalendarReportEvent(
        userId:
            event.userId,

        month:
            previous,
      ),
    );
  }

  // ============================================================
  // NEXT
  // ============================================================

  void _nextMonth(
    NextCalendarMonthEvent event,
    Emitter<CalendarReportState> emit,
  ) {
    final DateTime next =
        DateTime(
      state.visibleMonth.year,
      state.visibleMonth.month + 1,
      1,
    );

    add(
      LoadCalendarReportEvent(
        userId:
            event.userId,

        month:
            next,
      ),
    );
  }

  // ============================================================
  // TODAY
  // ============================================================

  void _today(
    TodayCalendarEvent event,
    Emitter<CalendarReportState> emit,
  ) {
    final DateTime now =
        DateTime.now();

    add(
      LoadCalendarReportEvent(
        userId:
            event.userId,

        month:
            DateTime(
          now.year,
          now.month,
          1,
        ),
      ),
    );
  }
}