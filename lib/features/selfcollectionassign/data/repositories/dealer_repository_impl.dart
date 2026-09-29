import 'package:solufine/features/selfcollectionassign/data/datasource/dealer_remote_datasource.dart';

import '../../domain/entities/dealer_response_entity.dart';
import '../../domain/repositories/dealer_repository.dart';

class DealerRepositoryImpl implements DealerRepository {
  final DealerRemoteDataSource remoteDataSource;

  DealerRepositoryImpl({required this.remoteDataSource});

  @override
  Future<DealerResponseEntity> getDealerList({required int userId}) async {
    return await remoteDataSource.getDealerList(userId: userId);
  }
}
