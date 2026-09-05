import 'package:demo/features/home/doman/home_entity/menu_entity.dart';
import 'package:demo/features/home/doman/home_repository/home_repo.dart';

class GetMenuUsecase {
  final HomeRepo homeRepo;

  GetMenuUsecase(this.homeRepo);

  Future<List<MenuEntity>> getMenus(int userId, String menuName) async {
    try {
      return await homeRepo.getMenus(userId, menuName);
    } catch (e) {
      throw Exception('Failed to fetch home menu: $e');
    }
  }
}
