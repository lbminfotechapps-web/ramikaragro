import '../../domain/entities/top_ten_dealer.dart';
import '../../domain/repositories/top_ten_dealer_repository.dart';
import '../datasources/top_ten_dealer_remote_data_source.dart';

class TopTenDealerRepositoryImpl
    implements TopTenDealerRepository {
  final TopTenDealerRemoteDataSource remoteDataSource;

  TopTenDealerRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<TopTenDealer>> getTopTenDealerVisit({
    required String userId,
    required int days,
  }) {
    return remoteDataSource.getTopTenDealerVisit(
      userId: userId,
      days: days,
    );
  }
}