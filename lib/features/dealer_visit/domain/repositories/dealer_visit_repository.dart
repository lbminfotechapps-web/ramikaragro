

// import 'package:solufine/features/dealer_visit/domain/entities/dealer_followup_list_entity.dart';
// import 'package:solufine/features/dealer_visit/domain/entities/visit_purpose_entity.dart';

// abstract class AddDealerVisitRepository {



//   Future<Map<String, dynamic>> addRemark(Map<String, dynamic> jsonData);

//   Future<List<PurposeEntity>> getPurpose(String userID);
  
 
// Future<List<DealerFollowupListEntity>> getFollowupList(String outlet_id);

//   Future<Map<String, dynamic>> addDealerFollowUp(Map<String, dynamic> jsonData);
 
//   Future<Map<String, dynamic>> updateDealerFollowUp(Map<String, dynamic> jsonData);
  
// }


import 'dart:io';

import 'package:solufine/features/dealer_visit/domain/entities/dealer_followup_list_entity.dart';
import 'package:solufine/features/dealer_visit/domain/entities/visit_purpose_entity.dart';

abstract class AddDealerVisitRepository {
  // ============================================================
  // ADD REMARK
  // ============================================================

  Future<Map<String, dynamic>> addRemark(
    Map<String, dynamic> jsonData,
  );

  // ============================================================
  // GET PURPOSE
  // ============================================================

  Future<List<PurposeEntity>> getPurpose(
    String userID,
  );

  // ============================================================
  // GET FOLLOWUP LIST
  // ============================================================

  Future<List<DealerFollowupListEntity>> getFollowupList(
    String outletId,
  );

  // ============================================================
  // ADD DEALER FOLLOW UP
  // ============================================================
  //
  // CHANGED:
  // File? image added separately.
  //
  // ============================================================

  Future<Map<String, dynamic>> addDealerFollowUp(
    Map<String, dynamic> jsonData,
    File? image,
  );

  // ============================================================
  // UPDATE DEALER FOLLOW UP
  // ============================================================

  Future<Map<String, dynamic>> updateDealerFollowUp(
    Map<String, dynamic> jsonData,
  );
}