import 'package:demo/features/dealer_visit/domain/entities/visit_purpose_entity.dart';

import '../repositories/dealer_visit_repository.dart';

class AddRemark {
  final AddDealerVisitRepository repository;

  AddRemark(this.repository);



  Future<Map<String, dynamic>> call(
    Map<String, dynamic> jsonData,
  ) async {
    try {
      return await repository.addRemark(jsonData);
    } catch (e) {
      throw Exception('Failed to save punch details: $e');
    }
  }
   Future<List<PurposeEntity>> getPurpose(String userId) async {
    try {
      return await repository.getPurpose(userId);
    } catch (e) {
      throw Exception('Failed to fetch home menu: $e');
    }
  }

}