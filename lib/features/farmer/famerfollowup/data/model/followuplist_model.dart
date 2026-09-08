class RemarkListModel {
  final String fldAdmName;
  final String fldFarmerName;
  final String fldDate;
  final String fldTime;
  final String fldRemark;
  final String fldStatusOfFarmer;

  const RemarkListModel({
    required this.fldAdmName,
    required this.fldFarmerName,
    required this.fldDate,
    required this.fldTime,
    required this.fldRemark,
    required this.fldStatusOfFarmer,
  });

  factory RemarkListModel.fromJson(Map<String, dynamic> json) {
    return RemarkListModel(
      fldAdmName: json['fld_adm_name']?.toString() ?? '',
      fldFarmerName: json['fld_farmer_name']?.toString() ?? '',
      fldDate: json['fld_date']?.toString() ?? '',
      fldTime: json['fld_time']?.toString() ?? '',
      fldRemark: json['fld_remark']?.toString() ?? '',
      fldStatusOfFarmer: json['fld_status_of_farmer']?.toString().trim() ?? '',
    );
  }
}
