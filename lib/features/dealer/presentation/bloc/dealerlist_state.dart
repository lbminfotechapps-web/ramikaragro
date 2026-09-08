import 'package:demo/features/dealer/data/models/DealerListModel.dart';
import 'package:demo/features/farmer/farmerlist/data/model/farmerlist_model.dart';

enum DealerListStatus {
  initial,
  loading,
  success,
  failure,
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