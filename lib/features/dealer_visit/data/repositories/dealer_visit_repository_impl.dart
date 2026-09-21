import 'package:solufine/features/dealer_visit/data/datasources/dealer_visit_data_source.dart';
import 'package:solufine/features/dealer_visit/domain/entities/dealer_followup_list_entity.dart';
import 'package:solufine/features/dealer_visit/domain/entities/visit_purpose_entity.dart';

import '../../domain/repositories/dealer_visit_repository.dart';

class DealerVisitRepositoryImpl implements AddDealerVisitRepository {
  final DealerVisitDataSource remoteDataSource;

  DealerVisitRepositoryImpl(this.remoteDataSource);

  @override
  Future<Map<String, dynamic>> addRemark(Map<String, dynamic> jsonData) {
    return remoteDataSource.addRemark(jsonData);
  }

  @override
  Future<List<PurposeEntity>> getPurpose(String userID) async {
    final menus = await remoteDataSource.getPurpose(userID);
    return menus;
  }

  @override
  Future<Map<String, dynamic>> addDealerFollowUp(
    Map<String, dynamic> jsonData,
  ) {
    return remoteDataSource.addDealerFollowUp(jsonData);
  }

  @override
  Future<Map<String, dynamic>> updateDealerFollowUp(
    Map<String, dynamic> jsonData,
  ) {
    return remoteDataSource.updateDealer(jsonData);
  }

 @override
  Future<List<DealerFollowupListEntity>> getFollowupList(String outletId) async {
    final menus = await remoteDataSource.getFollowupList(outletId);
    return menus;
  }
}
