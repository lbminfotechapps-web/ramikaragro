import 'package:demo/features/distpatchistory/domain/entities/dispatch_list_entity.dart';
import 'package:equatable/equatable.dart';

abstract class DispatchState extends Equatable {
  const DispatchState();

  @override
  List<Object?> get props => [];
}

class DispatchInitial extends DispatchState {
  const DispatchInitial();
}

class DispatchLoading extends DispatchState {
  const DispatchLoading();
}

class DispatchLoaded extends DispatchState {
  final List<DispatchListEntity> dispatchList;
  final bool hasMore;
  final bool isLoadingMore;

  const DispatchLoaded({
    required this.dispatchList,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  DispatchLoaded copyWith({
    List<DispatchListEntity>? dispatchList,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return DispatchLoaded(
      dispatchList: dispatchList ?? this.dispatchList,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [dispatchList, hasMore, isLoadingMore];
}

class DispatchEmpty extends DispatchState {
  const DispatchEmpty();
}

class DispatchError extends DispatchState {
  final String message;

  const DispatchError(this.message);

  @override
  List<Object?> get props => [message];
}
