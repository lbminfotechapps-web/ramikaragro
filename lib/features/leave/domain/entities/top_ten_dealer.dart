import 'package:equatable/equatable.dart';

import 'pre_details.dart';

class TopTenDealer extends Equatable {
  final String outletName;
  final String outletAddress;
  final String visitCount;
  final List<PreDetails> preDetails;

  const TopTenDealer({
    required this.outletName,
    required this.outletAddress,
    required this.visitCount,
    required this.preDetails,
  });

  @override
  List<Object?> get props => [
        outletName,
        outletAddress,
        visitCount,
        preDetails,
      ];
}