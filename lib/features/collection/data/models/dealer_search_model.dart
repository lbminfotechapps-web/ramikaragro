import '../../domain/entities/dealer_search_entity.dart';

// ============================================================================
// DEALER SEARCH RESPONSE MODEL
// ============================================================================

class DealerSearchResponseModel
    extends DealerSearchResponseEntity {
  const DealerSearchResponseModel({
    required super.status,
    required super.message,
    required super.result,
  });

  factory DealerSearchResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final dynamic resultData =
        json['result'];

    return DealerSearchResponseModel(
      status:
          json['status'] == true,

      message:
          json['message']
                  ?.toString() ??
              '',

      result:
          resultData is List
              ? resultData
                  .map(
                    (item) =>
                        DealerSearchModel
                            .fromJson(
                      Map<String, dynamic>.from(
                        item as Map,
                      ),
                    ),
                  )
                  .toList()
              : const [],
    );
  }
}

// ============================================================================
// DEALER MODEL
// ============================================================================

class DealerSearchModel
    extends DealerSearchEntity {
  const DealerSearchModel({
    required super.outletId,
    required super.outletName,
    required super.outletMobile,
    required super.geoAddress,
  });

  factory DealerSearchModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return DealerSearchModel(
      outletId:
          json['fld_outlet_id']
                  ?.toString()
                  .trim() ??
              '',

      outletName:
          json['fld_outlet_name']
                  ?.toString()
                  .trim() ??
              '',

      outletMobile:
          json['fld_outletper_mobile']
                  ?.toString()
                  .trim() ??
              '',

      geoAddress:
          json['fld_geo_address']
                  ?.toString()
                  .trim() ??
              '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fld_outlet_id':
          outletId,
      'fld_outlet_name':
          outletName,
      'fld_outletper_mobile':
          outletMobile,
      'fld_geo_address':
          geoAddress,
    };
  }
}