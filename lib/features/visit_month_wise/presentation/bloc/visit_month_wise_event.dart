abstract class VisitMonthWiseEvent {
  const VisitMonthWiseEvent();
}



class LoadVisitMonthWiseEvent extends VisitMonthWiseEvent {
  final String fromDate;
  final String toDate;
  final String employeeId;

  const LoadVisitMonthWiseEvent({
    required this.fromDate,
    required this.toDate,
    required this.employeeId,
  });
}



class LoadVisitDayWiseEvent extends VisitMonthWiseEvent {
  final String fromDate;
  final String toDate;
  final String employeeId;

  const LoadVisitDayWiseEvent({
    required this.fromDate,
    required this.toDate,
    required this.employeeId,
  });
}



class LoadVisitHourWiseEvent extends VisitMonthWiseEvent {
  final String fromDate;
  final String toDate;
  final String employeeId;

  const LoadVisitHourWiseEvent({
    required this.fromDate,
    required this.toDate,
    required this.employeeId,
  });
}



class LoadVisitFrequencyEvent extends VisitMonthWiseEvent {
  final String fromDate;
  final String toDate;
  final String employeeId;

  const LoadVisitFrequencyEvent({
    required this.fromDate,
    required this.toDate,
    required this.employeeId,
  });
}


class LoadVisitGeoWiseEvent extends VisitMonthWiseEvent {
  final String fromDate;
  final String toDate;
  final String employeeId;

  const LoadVisitGeoWiseEvent({
    required this.fromDate,
    required this.toDate,
    required this.employeeId,
  });
}


class LoadVisitTopListEvent extends VisitMonthWiseEvent {
  final String fromDate;
  final String toDate;
  final String employeeId;

  const LoadVisitTopListEvent({
    required this.fromDate,
    required this.toDate,
    required this.employeeId,
  });
}


class LoadVisitTopEmployeeEvent extends VisitMonthWiseEvent {
  final String fromDate;
  final String toDate;
  final String employeeId;

  const LoadVisitTopEmployeeEvent({
    required this.fromDate,
    required this.toDate,
    required this.employeeId,
  });
}



class SearchVisitReportEmployeesEvent extends VisitMonthWiseEvent {
  final String userId;
  final String searchText;

  const SearchVisitReportEmployeesEvent({
    required this.userId,
    required this.searchText,
  });
}


class ClearVisitReportEmployeesEvent extends VisitMonthWiseEvent {
  const ClearVisitReportEmployeesEvent();
}
