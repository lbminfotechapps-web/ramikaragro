import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_collection_type.dart';
import 'collection_type_event.dart';
import 'collection_type_state.dart';

class CollectionTypeBloc
    extends Bloc<CollectionTypeEvent, CollectionTypeState> {
  final GetCollectionType getCollectionType;

  CollectionTypeBloc({required this.getCollectionType})
    : super(const CollectionTypeState()) {
    on<GetCollectionTypeEvent>(_onGetCollectionType);

    on<RefreshCollectionTypeEvent>(_onRefreshCollectionType);
  }

  Future<void> _onGetCollectionType(
    GetCollectionTypeEvent event,
    Emitter<CollectionTypeState> emit,
  ) async {
    emit(state.copyWith(status: CollectionTypeStatus.loading, message: ''));

    try {
      final response = await getCollectionType();

      if (response.status) {
        emit(
          state.copyWith(
            status: CollectionTypeStatus.success,
            collectionTypes: response.collectionTypes,
            message: response.message,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: CollectionTypeStatus.failure,
            collectionTypes: const [],
            message: response.message,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: CollectionTypeStatus.failure,
          collectionTypes: const [],
          message: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onRefreshCollectionType(
    RefreshCollectionTypeEvent event,
    Emitter<CollectionTypeState> emit,
  ) async {
    try {
      final response = await getCollectionType();

      if (response.status) {
        emit(
          state.copyWith(
            status: CollectionTypeStatus.success,
            collectionTypes: response.collectionTypes,
            message: response.message,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: CollectionTypeStatus.failure,
            message: response.message,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: CollectionTypeStatus.failure,
          message: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}
