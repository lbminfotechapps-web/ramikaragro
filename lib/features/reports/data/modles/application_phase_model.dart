import '../../domain/entities/application_phase.dart';

class ApplicationPhaseModel extends ApplicationPhase {
  const ApplicationPhaseModel({required super.result});

  factory ApplicationPhaseModel.fromJson(Map<String, dynamic> json) {
    final result = int.tryParse(json['result']?.toString() ?? '');
    if (result == null) {
      throw const FormatException('Invalid application phase result');
    }
    return ApplicationPhaseModel(result: result);
  }
}
