import '../../domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: _getValue(
        json,
        [
          'category_id',
          'categoryId',
          'id',
          'fld_category_id',
        ],
      ),
      name: _getValue(
        json,
        [
          'category_name',
          'categoryName',
          'name',
          'fld_category_name',
        ],
      ),
    );
  }

  static String _getValue(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      if (json[key] != null) {
        return json[key].toString();
      }
    }

    return '';
  }
}