import 'package:demo/features/dealer_visit/data/datasources/dealer_visit_data_source.dart';
import 'package:demo/features/dealer_visit/domain/entities/visit_purpose_entity.dart';

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

}