class DealerModel {
  final String id;
  final String name;
  final String mobile;
  final String address;

  const DealerModel({
    required this.id,
    required this.name,
    this.mobile = '',
    this.address = '',
  });

  factory DealerModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return DealerModel(
      id: _readString(
        json,
        [
          'id',
          'dealerId',
          'dealer_id',
          'outletId',
          'outlet_id',
          'customerId',
          'customer_id',
          'fld_outlet_id',
          'fld_dealer_id',
        ],
      ),
      name: _readString(
        json,
        [
          'name',
          'dealerName',
          'dealer_name',
          'outletName',
          'outlet_name',
          'outletPersonName',
          'shopName',
          'fld_outlet_name',
          'fld_dealer_name',
        ],
      ),
      mobile: _readString(
        json,
        [
          'mobile',
          'mobileNo',
          'mobile_no',
          'outletMobile',
          'outletPersonMobile',
          'fld_outlet_person_mobile',
        ],
      ),
      address: _readString(
        json,
        [
          'address',
          'outletAddress',
          'outlet_address',
          'shopAddress',
          'fld_outlet_address',
        ],
      ),
    );
  }

  static String _readString(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key];

      if (value != null &&
          value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    return '';
  }
}