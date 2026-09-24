import 'package:solufine/features/dealer/data/models/DealerListModel.dart';


enum DealerListStatus {
  initial,
  loading,
  success,
  failure,
  addDealerloading,
  addDealerLocationSuccess
}

class DealerListState {
  final DealerListStatus status;
  final List<DealerListModel> dealerList;
  final String? errorMessage;

  const DealerListState({
    this.status = DealerListStatus.initial,
    this.dealerList = const [],
    this.errorMessage,
  });

  DealerListState copyWith({
    DealerListStatus? status,
    List<DealerListModel>? dealerList,
    String? errorMessage,
  }) {
    return DealerListState(
      status: status ?? this.status,
      dealerList: dealerList ?? this.dealerList,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}