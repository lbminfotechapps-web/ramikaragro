import 'package:demo/features/home/data/home_datasource/home_datasource.dart';
import 'package:demo/features/home/doman/home_entity/homevisit_entity.dart';
import 'package:demo/features/home/doman/home_entity/menu_entity.dart';
import 'package:demo/features/home/doman/home_repository/home_repo.dart';

class HomeRepoImp implements HomeRepo {
  final HomeDatasource homeDatasource;

  HomeRepoImp(this.homeDatasource);

  @override
  Future<List<MenuEntity>> getMenus(int userID, String menuName) async {
    final menus = await homeDatasource.fetchHomeMenu(userID, menuName);
    return menus;
  }

  @override
  Future<Map<String, dynamic>> getVisitCountGraph(
    int userId,
    String searchFromDate,
    String searchToDate,
  ) {
    return homeDatasource.fetchVisitCountGraph(
      userId,
      searchFromDate,
      searchToDate,
    );
  }

  @override
  Future<HomeVisitEntity> getHomeVisitCount({required String userId}) async {
    return await homeDatasource.getHomeVisitCount(userId: userId);
  }
}
