import 'package:equatable/equatable.dart';

class SubmitEnquiryEntity extends Equatable {
  final bool status;
  final String message;

  const SubmitEnquiryEntity({
    required this.status,
    required this.message,
  });

  @override
  List<Object?> get props => [
        status,
        message,
      ];
}