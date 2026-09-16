

import 'package:demo/features/dealer_visit/domain/entities/dealer_followup_list_entity.dart';
import 'package:demo/features/dealer_visit/domain/entities/visit_purpose_entity.dart';

abstract class AddDealerVisitRepository {



  Future<Map<String, dynamic>> addRemark(Map<String, dynamic> jsonData);

  Future<List<PurposeEntity>> getPurpose(String userID);
  
 
Future<List<DealerFollowupListEntity>> getFollowupList(String outlet_id);
  
}