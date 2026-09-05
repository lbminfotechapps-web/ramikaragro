

import 'package:demo/features/home/doman/home_entity/menu_entity.dart';

class MenuModel extends MenuEntity {
  const MenuModel({
    required super.menuId,
    required super.menuName,
    required super.iconImage,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      menuId: json['fld_menu_id']?.toString() ?? '',
      menuName: json['fld_menu_name']?.toString() ?? '',
      iconImage: json['fld_icon_image']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fld_menu_id': menuId,
      'fld_menu_name': menuName,
      'fld_icon_image': iconImage,
    };
  }
}