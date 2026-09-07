class RemarkListModel {
  final String fldAdmName;
  final String fldOutletName;
  final String fldDate;
  final String fldTime;
  final String fldRemark;

  const RemarkListModel({
    required this.fldAdmName,
    required this.fldOutletName,
    required this.fldDate,
    required this.fldTime,
    required this.fldRemark,
  });

  factory RemarkListModel.fromJson(Map<String, dynamic> json) {
    return RemarkListModel(
      fldAdmName: json['fld_adm_name']?.toString() ?? '',
      fldOutletName: json['fld_outlet_name']?.toString() ?? '',
      fldDate: json['fld_date']?.toString() ?? '',
      fldTime: json['fld_time']?.toString() ?? '',
      fldRemark: json['fld_remark']?.toString() ?? '',
    );
  }
}
