import 'package:equatable/equatable.dart';

import '../../domain/entities/top_ten_dealer.dart';

enum TopTenDealerStatus {
  initial,
  loading,
  success,
  failure,
}

class TopTenDealerState extends Equatable {
  final TopTenDealerStatus status;
  final List<TopTenDealer> dealers;
  final int selectedDays;
  final String? errorMessage;

  const TopTenDealerState({
    this.status = TopTenDealerStatus.initial,
    this.dealers = const [],
    this.selectedDays = 30,
    this.errorMessage,
  });

  TopTenDealerState copyWith({
    TopTenDealerStatus? status,
    List<TopTenDealer>? dealers,
    int? selectedDays,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TopTenDealerState(
      status: status ?? this.status,
      dealers: dealers ?? this.dealers,
      selectedDays:
          selectedDays ?? this.selectedDays,
      errorMessage:
          clearError
              ? null
              : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        dealers,
        selectedDays,
        errorMessage,
      ];
}