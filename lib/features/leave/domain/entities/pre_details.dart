import 'package:equatable/equatable.dart';

class PreDetails extends Equatable {
  final String formattedDate;
  final String visitCount;

  const PreDetails({
    required this.formattedDate,
    required this.visitCount,
  });

  @override
  List<Object?> get props => [
        formattedDate,
        visitCount,
      ];
}