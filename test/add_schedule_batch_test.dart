import 'package:flutter_test/flutter_test.dart';
import 'package:solufine/features/schedule/domain/entities/add_schedule_request.dart';
import 'package:solufine/features/schedule/domain/repositories/add_schedule_repository.dart';
import 'package:solufine/features/schedule/domain/usecases/submit_add_schedule.dart';
import 'package:solufine/features/schedule/presentation/bloc/add_schedule_submit_bloc.dart';

class RecordingRepository implements AddScheduleRepository {
  final calls = <AddScheduleRequest>[];
  bool failSecondDate = false;
  @override
  Future<AddScheduleResult> submit(AddScheduleRequest request) async {
    calls.add(request);
    if (failSecondDate && request.details.first.scheduleDate.day == 29) {
      throw Exception('Network failed');
    }
    return const AddScheduleResult(
      status: true,
      message: 'Saved',
      rawResponse: {},
    );
  }
}

AddScheduleRequest request(int day, int count) => AddScheduleRequest(
  empId: '4',
  plotId: '1',
  farmerId: '1',
  scheduleDate: DateTime(2026, 10, day),
  details: List.generate(
    count,
    (i) => AddScheduleDetail(
      productName: 'Product $day $i',
      cropId: '9',
      productType: 'Spray',
      productQty: '50',
      unit: 'Ltr',
      waterQty: '20',
      waterUnit: 'Ltr',
      remark: 'Remark $i',
      scheduleDate: DateTime(2026, 10, day),
    ),
  ),
);

void main() {
  test('final submit sends four and three products as two requests', () async {
    final repository = RecordingRepository();
    final bloc = AddScheduleSubmitBloc(
      submitAddSchedule: SubmitAddSchedule(repository),
    );
    addTearDown(bloc.close);
    final done = bloc.stream.firstWhere(
      (s) => s.status == AddScheduleSubmitStatus.success,
    );
    bloc.add(SendAddSchedule.batch([request(28, 4), request(29, 3)]));
    await done;
    expect(repository.calls, hasLength(2));
    expect(repository.calls[0].toJson()['scheduleDate'], '28-10-2026');
    expect(repository.calls[1].toJson()['scheduleDate'], '29-10-2026');
    expect(repository.calls[0].details, hasLength(4));
    expect(repository.calls[1].details, hasLength(3));
    expect(
      repository.calls[0].toJson()['details'].every(
        (p) => p['date'] == '2026-10-28',
      ),
      isTrue,
    );
    expect(
      repository.calls[1].toJson()['details'].every(
        (p) => p['date'] == '2026-10-29',
      ),
      isTrue,
    );
  });

  test('retry skips the date request already submitted successfully', () async {
    final repository = RecordingRepository()..failSecondDate = true;
    final bloc = AddScheduleSubmitBloc(
      submitAddSchedule: SubmitAddSchedule(repository),
    );
    addTearDown(bloc.close);
    final failed = bloc.stream.firstWhere(
      (s) => s.status == AddScheduleSubmitStatus.failure,
    );
    bloc.add(SendAddSchedule.batch([request(28, 4), request(29, 3)]));
    await failed;
    repository.failSecondDate = false;
    final done = bloc.stream.firstWhere(
      (s) => s.status == AddScheduleSubmitStatus.success,
    );
    bloc.add(SendAddSchedule.batch([request(28, 4), request(29, 3)]));
    await done;
    expect(repository.calls.map((r) => r.details.first.scheduleDate.day), [
      28,
      29,
      29,
    ]);
  });
}
