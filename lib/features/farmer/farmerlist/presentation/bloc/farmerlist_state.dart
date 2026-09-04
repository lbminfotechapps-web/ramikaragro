import 'package:demo/features/farmer/farmerlist/data/model/farmerlist_model.dart';

enum FarmerlistStatus { initial, loading, success, failure }

class FarmerListState {
  final FarmerlistStatus status;
  final String? errorMessage;
  final List<FarmerlistModel> farmerList;

  const FarmerListState({
    this.status = FarmerlistStatus.initial,
    this.errorMessage,
    this.farmerList = const [],
  });

  FarmerListState copyWith({
    FarmerlistStatus? status,
    String? errorMessage,
    List<FarmerlistModel>? farmerList,
  }) {
    return FarmerListState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      farmerList: farmerList ?? this.farmerList,
    );
  }
}
