class Statedata {
  final String? stateId;
  final String? stateName;

  Statedata({this.stateId, this.stateName});

  factory Statedata.fromJson(Map<String, dynamic> json) {
    return Statedata(
      stateId: json['state_id']?.toString(),
      stateName: json['state_name']?.toString(),
    );
  }
}
