import 'package:equatable/equatable.dart';

class PlantAnalysisEntity extends Equatable {
  final String marathiResult;
  final String englishResult;

  const PlantAnalysisEntity({
    required this.marathiResult,
    required this.englishResult,
  });

  @override
  List<Object?> get props => [
        marathiResult,
        englishResult,
      ];
}