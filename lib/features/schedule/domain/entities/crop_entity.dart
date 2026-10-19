import 'package:equatable/equatable.dart';

class CropEntity extends Equatable {
  final String cropName;

  const CropEntity({
    required this.cropName,
  });

  @override
  List<Object?> get props => [
        cropName,
      ];
}