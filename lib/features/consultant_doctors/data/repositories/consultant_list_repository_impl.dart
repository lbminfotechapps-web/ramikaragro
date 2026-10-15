
import '../../domain/entities/consultant_doctor.dart';
import '../../domain/repositories/consultant_list_repository.dart';

import '../datasources/consultant_list_remote_data_source.dart';
import '../models/consultant_doctor_api_model.dart';

class ConsultantListRepositoryImpl
    implements ConsultantListRepository {
  final ConsultantListRemoteDataSource remote;

  const ConsultantListRepositoryImpl({
    required this.remote,
  });

  @override
  Future<List<ConsultantDoctor>> getDoctors({
    required String userId,
    String search = '',
    String districtId = '',
    String talukaId = '',
  }) async {
    final response = await remote.getDoctors(
      userId: userId,
      search: search,
      districtId: districtId,
      talukaId: talukaId,
    );

    final doctors = response
        .map(
          (item) =>
              ConsultantDoctorApiModel.fromJson(item).entity,
        )
        .toList();

    doctors.sort(
      (a, b) => b.createdAt.compareTo(a.createdAt),
    );

    return doctors;
  }
}
