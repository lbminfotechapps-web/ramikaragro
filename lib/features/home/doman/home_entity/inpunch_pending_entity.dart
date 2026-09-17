

class InpunchPendingResponseEntity {
  final bool status;
  final String? message;
  final int totalRecursiveEmployee;
  final int pendingInpunchCount;
  final String? inpunchTime;
  final String? address;
  final List<InpunchPendingEntity> result;

  const InpunchPendingResponseEntity({
    required this.status,
    this.message,
    required this.totalRecursiveEmployee,
    required this.pendingInpunchCount,
    this.inpunchTime,
    this.address,
    required this.result,
  });
}



class InpunchPendingEntity {
  final String? fldAdmName;
  final String? fldReportingPerson;
  final String? fldMobileNo;

  const InpunchPendingEntity({
    this.fldAdmName,
    this.fldReportingPerson,
    this.fldMobileNo,
  });
}
