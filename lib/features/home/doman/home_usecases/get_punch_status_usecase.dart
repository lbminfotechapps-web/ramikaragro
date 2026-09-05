import 'package:demo/features/home/doman/home_entity/punch_stat_entity.dart';
import 'package:demo/features/home/doman/home_repository/qick_access_repo.dart';

class GetPunchStatusUsecase {
	final QickAccessRepo qickAccessRepo;

	GetPunchStatusUsecase(this.qickAccessRepo);

	Future<PunchStatEntity> getPunchStatus(int userId) async {
		try {
			return await qickAccessRepo.getPunchStatus(userId);
		} catch (e) {
			throw Exception('Failed to fetch punch status: $e');
		}
	}
}