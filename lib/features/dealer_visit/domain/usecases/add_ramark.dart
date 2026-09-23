// import 'package:solufine/features/dealer_visit/domain/entities/dealer_followup_list_entity.dart';
// import 'package:solufine/features/dealer_visit/domain/entities/visit_purpose_entity.dart';

// import '../repositories/dealer_visit_repository.dart';

// class AddRemark {
//   final AddDealerVisitRepository repository;

//   AddRemark(this.repository);

//   Future<Map<String, dynamic>> call(
//     Map<String, dynamic> jsonData,
//   ) async {
//     try {
//       final response = await repository.addRemark(jsonData);

//       print('AddRemark response: $response');

//       return response;
//     } catch (e) {
//       print('AddRemark error: $e');
//       rethrow;
//     }
//   }

//   Future<List<PurposeEntity>> getPurpose(String userId) async {
//     try {
//       return await repository.getPurpose(userId);
//     } catch (e) {
//       throw Exception('Failed to fetch home menu: $e');
//     }
//   }

//   Future<List<DealerFollowupListEntity>> getFollowupList(
//     String outlet_id,
//   ) async {
//     try {
//       return await repository.getFollowupList(outlet_id);
//     } catch (e) {
//       throw Exception('Failed to fetch home menu: $e');
//     }
//   }

//   Future<Map<String, dynamic>> addDealerFollowUp(
//     Map<String, dynamic> jsonData,
//   ) async {
//     return repository.addDealerFollowUp(jsonData);
//   }

//   Future<Map<String, dynamic>> updateDealerFollowUp(
//     Map<String, dynamic> jsonData,
//   ) async {
//     return repository.updateDealerFollowUp(jsonData);
//   }
// }

import 'dart:io';

import 'package:solufine/features/dealer_visit/domain/entities/dealer_followup_list_entity.dart';
import 'package:solufine/features/dealer_visit/domain/entities/visit_purpose_entity.dart';

import '../repositories/dealer_visit_repository.dart';

class AddRemark {
  final AddDealerVisitRepository repository;

  AddRemark(this.repository);

  // ============================================================
  // ADD REMARK
  // ============================================================

  Future<Map<String, dynamic>> call(
    Map<String, dynamic> jsonData,
  ) async {
    try {
      final response = await repository.addRemark(
        jsonData,
      );

      print('AddRemark response: $response');

      return response;
    } catch (e) {
      print('AddRemark error: $e');
      rethrow;
    }
  }

  // ============================================================
  // GET PURPOSE
  // ============================================================

  Future<List<PurposeEntity>> getPurpose(
    String userId,
  ) async {
    try {
      return await repository.getPurpose(
        userId,
      );
    } catch (e) {
      throw Exception(
        'Failed to fetch home menu: $e',
      );
    }
  }

  // ============================================================
  // GET FOLLOWUP LIST
  // ============================================================

  Future<List<DealerFollowupListEntity>> getFollowupList(
    String outletId,
  ) async {
    try {
      return await repository.getFollowupList(
        outletId,
      );
    } catch (e) {
      throw Exception(
        'Failed to fetch home menu: $e',
      );
    }
  }

 

  Future<Map<String, dynamic>> addDealerFollowUp(
    Map<String, dynamic> jsonData,
    File? image,
  ) async {
    try {
      print(
        '========== USECASE ADD DEALER FOLLOW UP ==========',
      );

      print(
        'JSON DATA COUNT: ${jsonData.length}',
      );

      if (image != null) {
        print(
          'IMAGE PATH: ${image.path}',
        );

        print(
          'IMAGE EXISTS: ${await image.exists()}',
        );

        if (await image.exists()) {
          print(
            'IMAGE SIZE: ${await image.length()} bytes',
          );
        }
      } else {
        print(
          'IMAGE: NULL',
        );
      }

      print(
        '==================================================',
      );

      return await repository.addDealerFollowUp(
        jsonData,
        image,
      );
    } catch (e) {
      print(
        'AddDealerFollowUp error: $e',
      );

      rethrow;
    }
  }

  // ============================================================
  // UPDATE DEALER FOLLOW UP
  // ============================================================

  Future<Map<String, dynamic>> updateDealerFollowUp(
    Map<String, dynamic> jsonData,
  ) async {
    return repository.updateDealerFollowUp(
      jsonData,
    );
  }
}