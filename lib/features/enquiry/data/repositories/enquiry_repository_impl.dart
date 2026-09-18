import '../../domain/entities/district_entity.dart';
import '../../domain/entities/state_entity.dart';
import '../../domain/entities/taluka_entity.dart';
import '../../domain/entities/submit_enquiry_entity.dart';
import '../../domain/repositories/enquiry_repository.dart';
import '../datasources/enquiry_remote_data_source.dart';

class EnquiryRepositoryImpl implements EnquiryRepository {
  final EnquiryRemoteDataSource remoteDataSource;

  EnquiryRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<StateEntity>> getStates({
    required String userId,
  }) async {
    return remoteDataSource.getStates(
      userId: userId,
    );
  }

  @override
  Future<List<DistrictEntity>> getDistricts({
    required String userId,
    required String stateId,
  }) async {
    return remoteDataSource.getDistricts(
      userId: userId,
      stateId: stateId,
    );
  }

  @override
  Future<List<TalukaEntity>> getTalukas({
    required String userId,
    required String districtId,
  }) async {
    return remoteDataSource.getTalukas(
      userId: userId,
      districtId: districtId,
    );
  }

  @override
  Future<SubmitEnquiryEntity> submitEnquiry({
    required Map<String, String> params,
  }) async {
    return remoteDataSource.submitEnquiry(
      params: params,
    );
  }
}