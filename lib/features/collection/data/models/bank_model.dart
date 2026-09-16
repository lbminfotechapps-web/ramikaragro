class BankModel {
  final String id;
  final String name;

  const BankModel({
    required this.id,
    required this.name,
  });

  factory BankModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return BankModel(
      id: _readString(
        json,
        [
          'id',
          'bankId',
          'bank_id',
          'BankId',
          'BANK_ID',
        ],
      ),
      name: _readString(
        json,
        [
          'name',
          'bankName',
          'bank_name',
          'BankName',
          'BANK_NAME',
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