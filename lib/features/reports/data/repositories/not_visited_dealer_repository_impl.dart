
import 'package:demo/features/reports/domain/repositories/not_visited_dealer_repository.dart';

import '../../domain/entities/not_visited_dealer.dart';
import '../datasources/not_visited_dealer_remote_data_source.dart';

class NotVisitedDealerRepositoryImpl
    implements NotVisitedDealerRepository {
  final NotVisitedDealerRemoteDataSource remoteDataSource;

  NotVisitedDealerRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<NotVisitedDealer>> getNotVisitedDealers({
    required int days,
    required int startLimit,
  }) async {
    final result =
        await remoteDataSource.getNotVisitedDealers(
      days: days,
      startLimit: startLimit,
    );

    return result;
  }
}

