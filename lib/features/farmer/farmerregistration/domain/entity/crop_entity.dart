import 'package:equatable/equatable.dart';

class CropEntity extends Equatable {
  final String fldCropId;
  final String fldCropName;

  const CropEntity({
    required this.fldCropId,
    required this.fldCropName,
  });

  @override
  List<Object?> get props => [
        fldCropId,
        fldCropName,
      ];
}