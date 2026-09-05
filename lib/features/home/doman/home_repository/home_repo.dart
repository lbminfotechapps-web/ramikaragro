import 'package:demo/features/home/doman/home_entity/menu_entity.dart';

abstract class HomeRepo {
  Future<List<MenuEntity>> getMenus(int userID, String menuName);
}
