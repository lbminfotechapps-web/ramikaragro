import '../../domain/entities/calendar_day_entity.dart';

// ============================================================
// PERSON MODEL
// ============================================================

class CalendarPersonModel extends CalendarPersonEntity {
  const CalendarPersonModel({
    required super.id,
    required super.name,
  });

  factory CalendarPersonModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CalendarPersonModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString().trim() ?? '',
    );
  }
}

// ============================================================
// DAY MODEL
// ============================================================

class CalendarDayModel extends CalendarDayEntity {
  const CalendarDayModel({
    required super.date,
    required super.totalCount,
    required super.dealerCount,
    required super.farmerCount,
    required super.dealers,
    required super.farmers,
  });

  factory CalendarDayModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final dynamic dealerData =
        json['dealers'];

    final dynamic farmerData =
        json['farmers'];

    final List<CalendarPersonEntity> dealers =
        dealerData is List
            ? dealerData
                .whereType<Map>()
                .map(
                  (item) =>
                      CalendarPersonModel.fromJson(
                    Map<String, dynamic>.from(
                      item,
                    ),
                  ),
                )
                .toList()
            : <CalendarPersonEntity>[];

    final List<CalendarPersonEntity> farmers =
        farmerData is List
            ? farmerData
                .whereType<Map>()
                .map(
                  (item) =>
                      CalendarPersonModel.fromJson(
                    Map<String, dynamic>.from(
                      item,
                    ),
                  ),
                )
                .toList()
            : <CalendarPersonEntity>[];

    return CalendarDayModel(
      date:
          DateTime.tryParse(
            json['date']?.toString() ?? '',
          ) ??
          DateTime.now(),

      totalCount:
          _toInt(
        json['total_count'],
      ),

      dealerCount:
          _toInt(
        json['dealer_count'],
      ),

      farmerCount:
          _toInt(
        json['farmer_count'],
      ),

      dealers: dealers,

      farmers: farmers,
    );
  }

  static int _toInt(
    dynamic value,
  ) {
    if (value is int) {
      return value;
    }

    return int.tryParse(
          value?.toString() ?? '0',
        ) ??
        0;
  }
}