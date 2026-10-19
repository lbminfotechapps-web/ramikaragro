import 'package:equatable/equatable.dart';

class ScheduleItemEntity extends Equatable {
  final String cropName;
  final String date;
  final String schedule;

  const ScheduleItemEntity({
    required this.cropName,
    required this.date,
    required this.schedule,
  });

  String get title => '$cropName ($date)';

  @override
  List<Object?> get props => [
        cropName,
        date,
        schedule,
      ];
}