import '../entities/district_entity.dart';
import '../entities/state_entity.dart';
import '../entities/taluka_entity.dart';
import '../entities/submit_enquiry_entity.dart';

abstract class EnquiryRepository {
  Future<List<StateEntity>> getStates({
    required String userId,
  });

  Future<List<DistrictEntity>> getDistricts({
    required String userId,
    required String stateId,
  });

  Future<List<TalukaEntity>> getTalukas({
    required String userId,
    required String districtId,
  });

  Future<SubmitEnquiryEntity> submitEnquiry({
    required Map<String, String> params,
  });
}