import 'package:equatable/equatable.dart';

class SubmitPaymentResponse extends Equatable {
  final bool status;
  final String result;
  final String message;

  const SubmitPaymentResponse({
    required this.status,
    required this.result,
    required this.message,
  });

  @override
  List<Object?> get props => [
        status,
        result,
        message,
      ];
}