import '../../domain/entities/pre_details.dart';

class PreDetailsModel extends PreDetails {
  const PreDetailsModel({
    required super.formattedDate,
    required super.visitCount,
  });

  factory PreDetailsModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return PreDetailsModel(
      //  API key is formatted_date
      formattedDate: json['formatted_date']?.toString() ?? '',
      //  API key is visit_count
      visitCount: json['visit_count']?.toString() ?? '0',
    );
  }
}