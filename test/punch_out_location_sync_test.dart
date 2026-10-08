import 'package:flutter_test/flutter_test.dart';
import 'package:solufine/core/location_tracking/app_database.dart';
import 'package:solufine/core/location_tracking/location_repository.dart';
import 'package:solufine/features/home/doman/home_repository/qick_access_repo.dart';
import 'package:solufine/features/home/doman/home_usecases/get_punch_status_usecase.dart';
import 'package:solufine/features/home/presentation/quick_aceess_bloc/quick_access_event.dart';
import 'package:solufine/features/home/presentation/quick_aceess_bloc/quick_access_state.dart';
import 'package:solufine/features/home/presentation/quick_aceess_bloc/quick_acess_bloc.dart';

class _PunchRepository implements QickAccessRepo {
  Map<String, dynamic> response = {'status': true};
  Object? uploadError;
  int uploadCalls = 0;
  @override
  Future<Map<String, dynamic>> storeLocationData(
    Map<String, dynamic> data,
  ) async {
    uploadCalls++;
    if (uploadError != null) throw uploadError!;
    return response;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Locations implements LocationRepository {
  int deletions = 0;
  bool failCleanup = false;
  @override
  Future<int> deleteAllExceptLastLocation(int userId) async {
    deletions++;
    if (failCleanup) throw StateError('Database unavailable');
    return 0;
  }

  @override
  Future<List<LocationHistoryData>> getAllLocations(int userId) async => [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _SavedPunchBloc extends QuickAcessBloc {
  _SavedPunchBloc(_PunchRepository punch, _Locations locations)
    : super(GetPunchStatusUsecase(punch), locations) {
    emit(
      const QuickAccessState(
        quickAccessStatus: QuickAccessStatus.punchStatusSuccess,
        dailyTranId: '398',
      ),
    );
  }
}

class _ShareSucceeded extends QuickAccessEvent {}

void main() {
  test(
    'share success uploads history once without repeating the share notification',
    () async {
      final punch = _PunchRepository();
      final locations = _Locations();
      final bloc = _SavedPunchBloc(punch, locations);
      addTearDown(bloc.close);
      bloc.on<_ShareSucceeded>((event, emit) {
        emit(
          bloc.state.copyWith(
            quickAccessStatus: QuickAccessStatus.locationAddedSucces,
          ),
        );
      });
      var shareNotifications = 0;
      final subscription = bloc.stream.listen((state) {
        if (state.quickAccessStatus == QuickAccessStatus.locationAddedSucces) {
          shareNotifications++;
          if (shareNotifications < 3) {
            bloc.add(StoreTrackLocation('14', '398', '[{"latitude":"19.96"}]'));
          }
        }
      });
      addTearDown(subscription.cancel);
      final uploaded = bloc.stream
          .firstWhere(
            (state) =>
                state.quickAccessStatus ==
                QuickAccessStatus.locationHistoryUploaded,
          )
          .timeout(const Duration(seconds: 2));
      bloc.add(_ShareSucceeded());
      await uploaded;
      expect(shareNotifications, 1);
      expect(punch.uploadCalls, 1);
      expect(locations.deletions, 1);
    },
  );
  test(
    'location upload rejection retains transaction and local history',
    () async {
      final punch = _PunchRepository()
        ..response = {'status': false, 'message': 'Error', 'result': []};
      final locations = _Locations();
      final bloc = _SavedPunchBloc(punch, locations);
      addTearDown(bloc.close);
      final result = bloc.stream.firstWhere(
        (state) => state.quickAccessStatus == QuickAccessStatus.failure,
      );
      bloc.add(StoreTrackLocation('14', '398', '[{"latitude":"19.96"}]'));
      final state = await result;
      expect(state.dailyTranId, '398');
      expect(state.errorMessage, 'Location history upload failed: Error');
      expect(locations.deletions, 0);
    },
  );

  test('location network failure retains local history', () async {
    final punch = _PunchRepository()..uploadError = StateError('Offline');
    final locations = _Locations();
    final bloc = _SavedPunchBloc(punch, locations);
    addTearDown(bloc.close);
    final result = bloc.stream.firstWhere(
      (state) => state.quickAccessStatus == QuickAccessStatus.failure,
    );
    bloc.add(StoreTrackLocation('14', '398', '[{"latitude":"19.96"}]'));
    final state = await result;
    expect(state.dailyTranId, '398');
    expect(state.errorMessage, contains('Offline'));
    expect(locations.deletions, 0);
  });

  test('accepted upload stays successful when local cleanup fails', () async {
    final locations = _Locations()..failCleanup = true;
    final bloc = _SavedPunchBloc(_PunchRepository(), locations);
    addTearDown(bloc.close);
    final result = bloc.stream.firstWhere(
      (state) =>
          state.quickAccessStatus ==
              QuickAccessStatus.locationHistoryUploaded ||
          state.quickAccessStatus == QuickAccessStatus.failure,
    );
    bloc.add(StoreTrackLocation('14', '398', '[{"latitude":"19.96"}]'));
    final state = await result;
    expect(state.quickAccessStatus, QuickAccessStatus.locationHistoryUploaded);
    expect(state.dailyTranId, '398');
    expect(locations.deletions, 1);
  });
}
