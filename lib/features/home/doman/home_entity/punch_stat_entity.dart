class PunchStatEntity {
  final String dailyTranId;
  final String date;
  final String time;
  final String inOutStatus;
  final String macAddress;
  final String startingKm;

  const PunchStatEntity({
    required this.dailyTranId,
    required this.date,
    required this.time,
    required this.inOutStatus,
    required this.macAddress,
    required this.startingKm,
  });
}