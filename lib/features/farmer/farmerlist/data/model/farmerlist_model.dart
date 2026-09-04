class FarmerlistModel {
  const FarmerlistModel({
    required this.farmerId,
    required this.farmerName,
    required this.farmerPhone,
    required this.farmerAddress,
    this.distance,
    this.lastVisitDateTime,
    this.lastDateTime,
    this.cropId,
    this.sowingDate,
    this.acre,
    this.irrigationId,
    this.currentProductUsed,
    this.productId,
    this.contactPersonName,
    this.mobileNo2,
    this.emailId,
    this.stateId,
    this.stateName,
    this.distId,
    this.distName,
    this.talukaId,
    this.talukaName,
    this.categoryId,
    this.city,
    this.isDownload,
    this.tractorMode,
    this.campaignRadio,
    this.remark,
    this.statusOfFarmer,
    this.farmerDemoType,
    this.farmerDemoTypeId,
    this.categoryName,
  });

  final String farmerId;
  final String farmerName;
  final String farmerPhone;
  final String farmerAddress;

  final String? distance;
  final String? lastVisitDateTime;
  final String? lastDateTime;
  final String? cropId;
  final String? sowingDate;
  final String? acre;
  final String? irrigationId;
  final String? currentProductUsed;
  final String? productId;
  final String? contactPersonName;
  final String? mobileNo2;
  final String? emailId;
  final String? stateId;
  final String? stateName;
  final String? distId;
  final String? distName;
  final String? talukaId;
  final String? talukaName;
  final String? categoryId;
  final String? city;
  final String? isDownload;
  final String? tractorMode;
  final String? campaignRadio;
  final String? remark;
  final String? statusOfFarmer;
  final String? farmerDemoType;
  final String? farmerDemoTypeId;
  final String? categoryName;

  factory FarmerlistModel.fromJson(Map<String, dynamic> json) {
    print('--------------------------------');
    print('PARSING FARMER JSON');
    print('Farmer JSON: $json');

    final farmer = FarmerlistModel(
      distance: _nullableString(json['distance']),

      farmerId: _stringValue(json['fld_farmer_id']),
      farmerName: _stringValue(json['fld_farmer_name']),
      farmerPhone: _stringValue(json['fld_mobile_no']),
      farmerAddress: _stringValue(json['fld_address']),

      lastVisitDateTime: _nullableString(json['last_visit_date_time']),
      lastDateTime: _nullableString(json['last_date_time']),
      cropId: _nullableString(json['fld_crop_id']),
      sowingDate: _nullableString(json['fld_sowing_date']),
      acre: _nullableString(json['fld_acre']),
      irrigationId: _nullableString(json['fld_irrigation_id']),
      currentProductUsed: _nullableString(json['fld_current_product_used']),
      productId: _nullableString(json['fld_product_id']),
      contactPersonName: _nullableString(json['fld_contact_person_name']),
      mobileNo2: _nullableString(json['fld_mobile_no2']),
      emailId: _nullableString(json['fld_email_id']),
      stateId: _nullableString(json['fld_state_id']),
      stateName: _nullableString(json['stateName']),
      distId: _nullableString(json['fld_dist_id']),
      distName: _nullableString(json['fld_dist_name']),
      talukaId: _nullableString(json['fld_taluka_id']),
      talukaName: _nullableString(json['talukaName']),
      categoryId: _nullableString(json['fld_category_id']),
      city: _nullableString(json['fld_city']),
      isDownload: _nullableString(json['fld_isdownload']),
      tractorMode: _nullableString(json['fld_tractor_mode']),
      campaignRadio: _nullableString(json['fld_campaign_radio']),
      remark: _nullableString(json['fld_remark']),
      statusOfFarmer: _nullableString(json['fld_status_of_farmer']),
      farmerDemoType: _nullableString(json['fld_farmer_demo_type']),
      farmerDemoTypeId: _nullableString(json['fld_farmer_demo_type_id']),
      categoryName: _nullableString(json['fld_category_name']),
    );

    print('MODEL CREATED');
    print('Farmer ID: ${farmer.farmerId}');
    print('Farmer Name: ${farmer.farmerName}');
    print('Farmer Phone: ${farmer.farmerPhone}');
    print('Farmer Address: ${farmer.farmerAddress}');
    print('Distance: ${farmer.distance}');

    return farmer;
  }

  Map<String, dynamic> toJson() {
    return {
      'distance': distance,
      'last_visit_date_time': lastVisitDateTime,
      'last_date_time': lastDateTime,
      'fld_crop_id': cropId,
      'fld_sowing_date': sowingDate,
      'fld_acre': acre,
      'fld_irrigation_id': irrigationId,
      'fld_current_product_used': currentProductUsed,
      'fld_product_id': productId,
      'fld_farmer_name': farmerName,
      'fld_contact_person_name': contactPersonName,
      'fld_farmer_id': farmerId,
      'fld_address': farmerAddress,
      'fld_mobile_no': farmerPhone,
      'fld_mobile_no2': mobileNo2,
      'fld_email_id': emailId,
      'fld_state_id': stateId,
      'stateName': stateName,
      'fld_dist_id': distId,
      'fld_dist_name': distName,
      'fld_taluka_id': talukaId,
      'talukaName': talukaName,
      'fld_category_id': categoryId,
      'fld_city': city,
      'fld_isdownload': isDownload,
      'fld_tractor_mode': tractorMode,
      'fld_campaign_radio': campaignRadio,
      'fld_remark': remark,
      'fld_status_of_farmer': statusOfFarmer,
      'fld_farmer_demo_type': farmerDemoType,
      'fld_farmer_demo_type_id': farmerDemoTypeId,
      'fld_category_name': categoryName,
    };
  }

  static String _stringValue(Object? value) {
    return value?.toString() ?? '';
  }

  static String? _nullableString(Object? value) {
    return value?.toString();
  }
}
