
import '../../domain/entities/add_schedule_request.dart';
import '../../domain/repositories/add_schedule_repository.dart';

import '../datasources/add_schedule_remote_data_source.dart';
import '../models/add_schedule_model.dart';

class AddScheduleRepositoryImpl
    implements AddScheduleRepository {
  final AddScheduleRemoteDataSource remote;

  const AddScheduleRepositoryImpl({
    required this.remote,
  });

  @override
  Future<AddScheduleResult> submit(
    AddScheduleRequest request,
  ) async {
    final payload = AddScheduleModel.encode(request);

    final response = await remote.submit(payload);

    final result = AddScheduleModel.parse(response);

    if (!result.status) {
      throw Exception(result.message);
    }

    return result;
  }
}
