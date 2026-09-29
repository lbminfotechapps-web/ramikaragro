import '../../domain/entities/dealer_response_entity.dart';
import 'dealer_model.dart';

class DealerResponseModel extends DealerResponseEntity {
  const DealerResponseModel({
    required super.dealers,
    required super.status,
    required super.message,
  });

  factory DealerResponseModel.fromJson(Map<String, dynamic> json) {
    final result = json['result'];

    return DealerResponseModel(
      dealers: result is List
          ? result
                .map((e) => DealerModel.fromJson(Map<String, dynamic>.from(e)))
                .toList()
          : [],
      status: json['status'] ?? false,
      message: json['message']?.toString() ?? '',
    );
  }
}
