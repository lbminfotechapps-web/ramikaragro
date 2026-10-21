import 'package:equatable/equatable.dart';

class CropEntity extends Equatable {
  final String cropName;
  final String cropId;

  const CropEntity({required this.cropName, this.cropId = ''});

  @override
  List<Object?> get props => [cropName, cropId];
}
