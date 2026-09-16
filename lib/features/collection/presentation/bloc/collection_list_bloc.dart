import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_collection_list.dart';

import 'collection_list_event.dart';
import 'collection_list_state.dart';

class CollectionListBloc
    extends Bloc<CollectionListEvent, CollectionListState> {

  final GetCollectionList getCollectionList;

  CollectionListBloc({
    required this.getCollectionList,
  }) : super(const CollectionListState()) {

    on<GetCollectionListEvent>(
      _onGetCollectionList,
    );
  }

  Future<void> _onGetCollectionList(
    GetCollectionListEvent event,
    Emitter<CollectionListState> emit,
  ) async {

    print('==========================================');
    print('BLOC: GET COLLECTION LIST EVENT');
    print('userId: ${event.userId}');
    print('month: ${event.strMonth}');
    print('status: ${event.strStatus}');
    print('startLimit: ${event.startLimit}');
    print('pageSize: ${event.pageSize}');
    print('==========================================');

    emit(
      state.copyWith(
        status: CollectionListStatus.loading,
        errorMessage: '',
      ),
    );

    try {

      final result = await getCollectionList(
        userId: event.userId,
        strMonth: event.strMonth,
        strStatus: event.strStatus,
        startLimit: event.startLimit,
        pageSize: event.pageSize,
      );

      print('==========================================');
      print('BLOC SUCCESS');
      print('RECORD COUNT: ${result.length}');
      print('==========================================');

      emit(
        state.copyWith(
          status: CollectionListStatus.success,
          collectionList: result,
          errorMessage: '',
        ),
      );

    } catch (e) {

      print('==========================================');
      print('BLOC FAILURE');
      print('ERROR: $e');
      print('==========================================');

      emit(
        state.copyWith(
          status: CollectionListStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}