import 'package:demo/features/dealer_visit/domain/entities/add_dealer_visit_entity.dart';

class AddDealerVisitModel extends AddDealerVisitEntity {
  const AddDealerVisitModel({
    required super.outlet_id,
   
  });

  factory AddDealerVisitModel.fromJson(Map<String, dynamic> json) {
    return AddDealerVisitModel(
      outlet_id: json['outlet_id']?.toString() ?? ''

     
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'outlet_id': outlet_id,
     
    };
  }
}
