import '../../domain/entities/dealer_entity.dart';

class DealerModel extends DealerEntity {
  const DealerModel({
    required super.id,
    required super.name,
    required super.mobile,
    required super.address,
  });

  factory DealerModel.fromJson(Map<String, dynamic> json) {
    return DealerModel(
      id: _getValue(
        json,
        [
          'outlet_id',
          'outletId',
          'id',
          'fld_outlet_id',
        ],
      ),
      name: _getValue(
        json,
        [
          'outlet_name',
          'outletName',
          'name',
          'fld_outlet_name',
        ],
      ),
      mobile: _getValue(
        json,
        [
          'mobile',
          'mobile_no',
          'fld_outletper_mobile',
        ],
      ),
      address: _getValue(
        json,
        [
          'address',
          'outlet_address',
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